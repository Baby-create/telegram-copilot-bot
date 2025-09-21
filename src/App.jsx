import React, { useState } from 'react';
import ResizableVideo from './components/ResizableVideo';
import './App.css';

const App = () => {
  const [videoSrc, setVideoSrc] = useState('');
  const [showDemo, setShowDemo] = useState(false);

  // Sample video URLs for demonstration
  const sampleVideos = [
    {
      name: 'Big Buck Bunny (MP4)',
      url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
    },
    {
      name: 'Elephant Dream (MP4)', 
      url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'
    },
    {
      name: 'Sintel (MP4)',
      url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'
    }
  ];

  const handleVideoSelect = (url) => {
    setVideoSrc(url);
    setShowDemo(true);
  };

  const handleCustomVideoSubmit = (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const customUrl = formData.get('customUrl');
    if (customUrl) {
      setVideoSrc(customUrl);
      setShowDemo(true);
    }
  };

  const resetDemo = () => {
    setShowDemo(false);
    setVideoSrc('');
  };

  return (
    <div className="app">
      <header className="app-header">
        <h1>🤖 Telegram Copilot Bot</h1>
        <h2>ResizableVideo 组件演示</h2>
        <p>可拖拽和缩放的视频窗口组件</p>
      </header>

      {!showDemo ? (
        <main className="app-main">
          <div className="video-selector">
            <h3>选择演示视频</h3>
            
            <div className="sample-videos">
              <h4>示例视频：</h4>
              {sampleVideos.map((video, index) => (
                <button
                  key={index}
                  className="video-button"
                  onClick={() => handleVideoSelect(video.url)}
                >
                  {video.name}
                </button>
              ))}
            </div>

            <div className="custom-video">
              <h4>或输入自定义视频URL：</h4>
              <form onSubmit={handleCustomVideoSubmit} className="custom-form">
                <input
                  type="url"
                  name="customUrl"
                  placeholder="https://example.com/video.mp4"
                  className="url-input"
                />
                <button type="submit" className="submit-button">
                  加载视频
                </button>
              </form>
            </div>

            <div className="features">
              <h4>组件功能：</h4>
              <ul>
                <li>✨ 鼠标拖拽移动窗口位置</li>
                <li>🔄 八个方向的缩放控制点</li>
                <li>📐 最小/最大尺寸限制</li>
                <li>🎯 边界检测和约束</li>
                <li>🎮 原生视频控制器支持</li>
                <li>💫 流畅的动画和过渡效果</li>
              </ul>
            </div>
          </div>
        </main>
      ) : (
        <main className="app-demo">
          <div className="demo-controls">
            <button onClick={resetDemo} className="reset-button">
              ← 返回选择页面
            </button>
            <div className="demo-info">
              <span>拖拽视频窗口移动位置，拖拽边角和边缘进行缩放</span>
            </div>
          </div>
          
          <div className="demo-area">
            <ResizableVideo
              src={videoSrc}
              initialWidth={500}
              initialHeight={300}
              minWidth={250}
              minHeight={150}
              maxWidth={800}
              maxHeight={600}
            />
          </div>
        </main>
      )}

      <footer className="app-footer">
        <p>
          由 <strong>Telegram Copilot Bot</strong> 提供支持 | 
          <a href="https://github.com/Baby-create/telegram-copilot-bot" target="_blank" rel="noopener noreferrer">
            GitHub
          </a>
        </p>
      </footer>
    </div>
  );
};

export default App;