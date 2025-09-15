import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/pixel_button.dart';
import '../services/gacha_service.dart';
import '../services/points_service.dart';
import '../services/inventory_service.dart';
import '../models/gacha_item.dart';

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> {
  final GachaService _gachaService = GachaService();
  final PointsService _pointsService = PointsService();
  final InventoryService _inventoryService = InventoryService();
  
  int _currentPoints = 500; // TODO: 실제 포인트 연동
  Map<ItemRarity, int> _pityCounters = {};
  bool _isPerformingGacha = false;

  @override
  void initState() {
    super.initState();
    _pityCounters = _gachaService.createInitialPityCounters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('가챠'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.casino,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                '가챠 시스템',
                style: TextStyle(
                  color: AppColors.pixelWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '포인트를 사용해 아이템을 뽑아보세요!',
                style: TextStyle(
                  color: AppColors.pixelWhite.withOpacity(0.8),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '보유 포인트: $_currentPoints P',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: PixelButton(
                        text: '1회 뽑기 (100P)',
                        isLarge: true,
                        onPressed: _isPerformingGacha || _currentPoints < PointsService.singleGachaCost 
                          ? null 
                          : () => _performSingleGacha(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: PixelButton(
                        text: '10회 뽑기 (900P)',
                        isLarge: true,
                        onPressed: _isPerformingGacha || _currentPoints < PointsService.tenGachaCost 
                          ? null 
                          : () => _performTenGacha(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'TODO: 가챠 시스템 구현 예정',
                style: TextStyle(
                  color: AppColors.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 단일 가챠 실행
  void _performSingleGacha() async {
    setState(() {
      _isPerformingGacha = true;
    });

    try {
      // 포인트 차감
      setState(() {
        _currentPoints -= PointsService.singleGachaCost;
      });

      // 가챠 실행
      GachaResult result = _gachaService.performSingleGacha(_pityCounters);
      
      // 천장 카운터 업데이트
      _pityCounters = result.pityCounters;

      // 인벤토리에 아이템 추가
      _inventoryService.addItem(result.item);

      // 결과 표시
      await _showGachaResult([result]);

    } catch (e) {
      // 에러 발생 시 포인트 복구
      setState(() {
        _currentPoints += PointsService.singleGachaCost;
      });
      
      _showErrorDialog('가챠 실행 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isPerformingGacha = false;
      });
    }
  }

  /// 10연차 가챠 실행
  void _performTenGacha() async {
    setState(() {
      _isPerformingGacha = true;
    });

    try {
      // 포인트 차감
      setState(() {
        _currentPoints -= PointsService.tenGachaCost;
      });

      // 10연차 가챠 실행
      List<GachaResult> results = _gachaService.performTenGacha(_pityCounters);
      
      // 마지막 결과의 천장 카운터로 업데이트
      if (results.isNotEmpty) {
        _pityCounters = results.last.pityCounters;
      }

      // 인벤토리에 모든 아이템 추가
      for (final result in results) {
        _inventoryService.addItem(result.item);
      }

      // 결과 표시
      await _showGachaResult(results);

    } catch (e) {
      // 에러 발생 시 포인트 복구
      setState(() {
        _currentPoints += PointsService.tenGachaCost;
      });
      
      _showErrorDialog('가챠 실행 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isPerformingGacha = false;
      });
    }
  }

  /// 가챠 결과 표시 다이얼로그
  Future<void> _showGachaResult(List<GachaResult> results) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          results.length == 1 ? '가챠 결과' : '10연차 가챠 결과',
          style: TextStyle(color: AppColors.onSurface),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final item = result.item;
              
              return Card(
                color: _getRarityColor(item.rarity).withOpacity(0.2),
                child: ListTile(
                  leading: Icon(
                    _getSlotIcon(item.slot),
                    color: _getRarityColor(item.rarity),
                    size: 32,
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description,
                        style: TextStyle(color: AppColors.onSurface.withOpacity(0.8)),
                      ),
                      Text(
                        '${item.rarityDisplayName} · ${item.slotDisplayName}',
                        style: TextStyle(
                          color: _getRarityColor(item.rarity),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (result.wasPityActivated)
                        Text(
                          '천장 발동!',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('오류', style: TextStyle(color: AppColors.onSurface)),
        content: Text(message, style: TextStyle(color: AppColors.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  /// 희귀도에 따른 색상 반환
  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey;
      case ItemRarity.uncommon:
        return Colors.green;
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
    }
  }

  /// 슬롯에 따른 아이콘 반환
  IconData _getSlotIcon(ItemSlot slot) {
    switch (slot) {
      case ItemSlot.headwear:
        return Icons.sports_baseball;
      case ItemSlot.shirt:
        return Icons.checkroom;
      case ItemSlot.pants:
        return Icons.content_cut;
      case ItemSlot.shoes:
        return Icons.directions_walk;
      case ItemSlot.accessory:
        return Icons.visibility;
      case ItemSlot.effect:
        return Icons.auto_awesome;
    }
  }
}