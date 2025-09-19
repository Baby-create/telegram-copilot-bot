import React, { useState, useRef, useEffect } from 'react';
import './ResizableVideo.css';

const ResizableVideo = ({ 
  src, 
  initialWidth = 400, 
  initialHeight = 300, 
  minWidth = 200, 
  minHeight = 150,
  maxWidth = 800,
  maxHeight = 600
}) => {
  const [dimensions, setDimensions] = useState({
    width: initialWidth,
    height: initialHeight
  });
  const [position, setPosition] = useState({ x: 50, y: 50 });
  const [isDragging, setIsDragging] = useState(false);
  const [isResizing, setIsResizing] = useState(false);
  const [resizeHandle, setResizeHandle] = useState(null);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [positionStart, setPositionStart] = useState({ x: 0, y: 0 });
  const [dimensionsStart, setDimensionsStart] = useState({ width: 0, height: 0 });

  const videoRef = useRef(null);
  const containerRef = useRef(null);

  // Handle mouse down for dragging
  const handleMouseDown = (e) => {
    if (e.target.classList.contains('resize-handle')) {
      // Resizing
      setIsResizing(true);
      setResizeHandle(e.target.getAttribute('data-direction'));
      setDragStart({ x: e.clientX, y: e.clientY });
      setDimensionsStart({ ...dimensions });
    } else {
      // Dragging
      setIsDragging(true);
      setDragStart({ x: e.clientX, y: e.clientY });
      setPositionStart({ ...position });
    }
    e.preventDefault();
  };

  // Handle mouse move for dragging and resizing
  const handleMouseMove = (e) => {
    if (isDragging) {
      const deltaX = e.clientX - dragStart.x;
      const deltaY = e.clientY - dragStart.y;
      
      setPosition({
        x: Math.max(0, Math.min(window.innerWidth - dimensions.width, positionStart.x + deltaX)),
        y: Math.max(0, Math.min(window.innerHeight - dimensions.height, positionStart.y + deltaY))
      });
    } else if (isResizing && resizeHandle) {
      const deltaX = e.clientX - dragStart.x;
      const deltaY = e.clientY - dragStart.y;
      
      let newWidth = dimensionsStart.width;
      let newHeight = dimensionsStart.height;
      let newX = position.x;
      let newY = position.y;

      switch (resizeHandle) {
        case 'se': // Southeast
          newWidth = Math.max(minWidth, Math.min(maxWidth, dimensionsStart.width + deltaX));
          newHeight = Math.max(minHeight, Math.min(maxHeight, dimensionsStart.height + deltaY));
          break;
        case 'sw': // Southwest
          newWidth = Math.max(minWidth, Math.min(maxWidth, dimensionsStart.width - deltaX));
          newHeight = Math.max(minHeight, Math.min(maxHeight, dimensionsStart.height + deltaY));
          newX = position.x + (dimensionsStart.width - newWidth);
          break;
        case 'ne': // Northeast
          newWidth = Math.max(minWidth, Math.min(maxWidth, dimensionsStart.width + deltaX));
          newHeight = Math.max(minHeight, Math.min(maxHeight, dimensionsStart.height - deltaY));
          newY = position.y + (dimensionsStart.height - newHeight);
          break;
        case 'nw': // Northwest
          newWidth = Math.max(minWidth, Math.min(maxWidth, dimensionsStart.width - deltaX));
          newHeight = Math.max(minHeight, Math.min(maxHeight, dimensionsStart.height - deltaY));
          newX = position.x + (dimensionsStart.width - newWidth);
          newY = position.y + (dimensionsStart.height - newHeight);
          break;
        case 'n': // North
          newHeight = Math.max(minHeight, Math.min(maxHeight, dimensionsStart.height - deltaY));
          newY = position.y + (dimensionsStart.height - newHeight);
          break;
        case 's': // South
          newHeight = Math.max(minHeight, Math.min(maxHeight, dimensionsStart.height + deltaY));
          break;
        case 'e': // East
          newWidth = Math.max(minWidth, Math.min(maxWidth, dimensionsStart.width + deltaX));
          break;
        case 'w': // West
          newWidth = Math.max(minWidth, Math.min(maxWidth, dimensionsStart.width - deltaX));
          newX = position.x + (dimensionsStart.width - newWidth);
          break;
      }

      setDimensions({ width: newWidth, height: newHeight });
      setPosition({ x: newX, y: newY });
    }
  };

  // Handle mouse up to stop dragging/resizing
  const handleMouseUp = () => {
    setIsDragging(false);
    setIsResizing(false);
    setResizeHandle(null);
  };

  // Add global event listeners for mouse move and up
  useEffect(() => {
    if (isDragging || isResizing) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      
      return () => {
        document.removeEventListener('mousemove', handleMouseMove);
        document.removeEventListener('mouseup', handleMouseUp);
      };
    }
  }, [isDragging, isResizing, dragStart, positionStart, dimensionsStart, position, dimensions, resizeHandle]);

  // Prevent text selection while dragging
  useEffect(() => {
    if (isDragging || isResizing) {
      document.body.style.userSelect = 'none';
      document.body.style.cursor = isDragging ? 'grabbing' : 'nw-resize';
    } else {
      document.body.style.userSelect = '';
      document.body.style.cursor = '';
    }

    return () => {
      document.body.style.userSelect = '';
      document.body.style.cursor = '';
    };
  }, [isDragging, isResizing]);

  const containerStyle = {
    position: 'absolute',
    left: position.x,
    top: position.y,
    width: dimensions.width,
    height: dimensions.height,
    border: '2px solid #007bff',
    borderRadius: '8px',
    overflow: 'hidden',
    cursor: isDragging ? 'grabbing' : 'grab',
    boxShadow: '0 4px 12px rgba(0, 123, 255, 0.3)',
    backgroundColor: '#000',
    userSelect: 'none'
  };

  return (
    <div
      ref={containerRef}
      className="resizable-video-container"
      style={containerStyle}
      onMouseDown={handleMouseDown}
    >
      <video
        ref={videoRef}
        src={src}
        width="100%"
        height="100%"
        controls
        style={{ display: 'block', pointerEvents: 'auto' }}
        onMouseDown={(e) => e.stopPropagation()} // Prevent dragging when interacting with video controls
      >
        您的浏览器不支持视频播放。
      </video>
      
      {/* Resize handles */}
      <div className="resize-handle resize-handle-nw" data-direction="nw" />
      <div className="resize-handle resize-handle-n" data-direction="n" />
      <div className="resize-handle resize-handle-ne" data-direction="ne" />
      <div className="resize-handle resize-handle-w" data-direction="w" />
      <div className="resize-handle resize-handle-e" data-direction="e" />
      <div className="resize-handle resize-handle-sw" data-direction="sw" />
      <div className="resize-handle resize-handle-s" data-direction="s" />
      <div className="resize-handle resize-handle-se" data-direction="se" />
    </div>
  );
};

export default ResizableVideo;