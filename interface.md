<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>랜덤 산책로 메이커</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/feather-icons"></script>
    <script src="https://cdn.jsdelivr.net/npm/feather-icons/dist/feather.min.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap');
        
        body {
            font-family: 'Press Start 2P', cursive;
            background-color: #000;
            height: 100vh;
            overflow: hidden;
            image-rendering: pixelated;
            color: #fff;
        }
        
        .pixel-border {
            border-style: solid;
            border-width: 4px;
            border-color: #fff #777 #777 #fff;
            box-shadow: 2px 2px 0 rgba(255,255,255,0.1);
        }
        
        .pixel-border-inset {
            border-style: solid;
            border-width: 4px;
            border-color: #999 #fff #fff #999;
        }
        
        .pixel-text {
            text-shadow: 2px 2px 0 rgba(0,0,0,0.2);
            letter-spacing: 1px;
        }
        
        
        .walk-animation {
            animation: walk 1s steps(4) infinite;
        }
        
        @keyframes walk {
            from { background-position: 0 0; }
            to { background-position: -512px 0; }
        }
        
        .pixel-cloud {
            animation: cloudMove 60s linear infinite;
        }
        
        @keyframes cloudMove {
            from { transform: translateX(100vw); }
            to { transform: translateX(-100px); }
        }
    </style>
</head>
<body class="flex flex-col items-center justify-center p-4">
    <!-- Title will be replaced with logo -->
    <div class="mb-12" id="logo-placeholder"></div>
    
    <!-- Main Buttons -->
    <div class="flex flex-col gap-4 w-full max-w-sm mb-16">
        <button class="pixel-border bg-black hover:bg-gray-900 text-white font-bold py-3 px-6 rounded-none text-sm pixel-text transform hover:scale-105 transition-transform">
            산책 시작하기
        </button>
        <button class="pixel-border bg-black hover:bg-gray-900 text-white font-bold py-3 px-6 rounded-none text-sm pixel-text transform hover:scale-105 transition-transform">
            기록 보기
        </button>
    </div>
    
    <!-- Character -->
    <div class="relative mb-16">
        <div class="w-32 h-48 bg-[url('https://i.imgur.com/8ZzXJ4R.png')] walk-animation bg-[length:512px_48px]"></div>
    </div>
    
    <!-- Secondary Buttons -->
    <div class="flex gap-6">
        <button class="pixel-border bg-black hover:bg-gray-900 text-white font-bold py-1 px-4 rounded-none text-xs pixel-text flex items-center gap-2">
            <i data-feather="dollar-sign" class="w-3 h-3"></i>
            상점
        </button>
        <button class="pixel-border bg-black hover:bg-gray-900 text-white font-bold py-1 px-4 rounded-none text-xs pixel-text flex items-center gap-2">
            <i data-feather="shirt" class="w-3 h-3"></i>
            옷장
        </button>
    </div>
    
    <!-- Background Elements -->
    <div class="absolute top-0 left-0 w-full h-full -z-10 overflow-hidden">
        <div class="absolute top-20 right-20 w-16 h-8 bg-gray-800 opacity-30 pixel-cloud" style="clip-path: polygon(0% 50%, 20% 0%, 80% 0%, 100% 50%, 80% 100%, 20% 100%)"></div>
        <div class="absolute top-40 left-10 w-24 h-12 bg-gray-800 opacity-30 pixel-cloud" style="clip-path: polygon(0% 50%, 20% 0%, 80% 0%, 100% 50%, 80% 100%, 20% 100%)"></div>
        <div class="absolute top-60 right-40 w-20 h-10 bg-gray-800 opacity-30 pixel-cloud" style="clip-path: polygon(0% 50%, 20% 0%, 80% 0%, 100% 50%, 80% 100%, 20% 100%)"></div>
    </div>
    
    <script>
        feather.replace();
        
        // Simple parallax effect
        document.addEventListener('mousemove', (e) => {
            const x = e.clientX / window.innerWidth;
            const y = e.clientY / window.innerHeight;
            
            document.querySelector('body').style.backgroundPosition = `${x * 20}px ${y * 20}px`;
        });
    </script>
</body>
</html>
