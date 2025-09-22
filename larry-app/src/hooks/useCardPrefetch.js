import { useState, useEffect, useCallback, useRef } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';

// Buffer configuration
const RENDER_AHEAD = 2; // next two mounted
const RENDER_BEHIND = 1; // previous one mounted
const DATA_AHEAD = 5; // data buffer ahead
const DATA_BEHIND = 3; // data buffer behind

export function useCardPrefetch({
  userId,
  currentIndex,
  onFetchMore,
  onFetchPrevious,
  hasNextCursor,
  hasPreviousCursor,
}) {
  const queryClient = useQueryClient();
  const [renderBuffer, setRenderBuffer] = useState([]);
  const [dataBuffer, setDataBuffer] = useState([]);
  const lastFetchedIndex = useRef(0);

  // Calculate buffer ranges
  const renderStart = Math.max(0, currentIndex - RENDER_BEHIND);
  const renderEnd = currentIndex + RENDER_AHEAD;
  const dataStart = Math.max(0, currentIndex - DATA_BEHIND);
  const dataEnd = currentIndex + DATA_AHEAD;

  // Ensure render buffer is populated
  const ensureRenderBuffer = useCallback((start, end) => {
    setRenderBuffer(prev => {
      const newBuffer = [...prev];
      
      // Add missing items to render buffer
      for (let i = start; i <= end; i++) {
        if (!newBuffer[i]) {
          // Placeholder for missing items
          newBuffer[i] = { id: `placeholder-${i}`, isLoading: true };
        }
      }
      
      return newBuffer;
    });
  }, []);

  // Ensure data buffer is populated
  const ensureDataBuffer = useCallback((start, end) => {
    setDataBuffer(prev => {
      const newBuffer = [...prev];
      
      // Add missing items to data buffer
      for (let i = start; i <= end; i++) {
        if (!newBuffer[i]) {
          newBuffer[i] = { id: `data-placeholder-${i}`, isLoading: true };
        }
      }
      
      return newBuffer;
    });
  }, []);

  // Handle index changes
  useEffect(() => {
    // Ensure render buffer for current index
    ensureRenderBuffer(renderStart, renderEnd);
    
    // Ensure data buffer for current index
    ensureDataBuffer(dataStart, dataEnd);
    
    // Trigger fetch if we're near the end
    if (currentIndex >= renderBuffer.length - 2 && hasNextCursor) {
      console.log('Near end detected, fetching more...');
      onFetchMore?.();
    }
    
    // Trigger fetch if we're near the beginning
    if (currentIndex <= 1 && hasPreviousCursor) {
      console.log('Near beginning detected, fetching previous...');
      onFetchPrevious?.();
    }
  }, [
    currentIndex,
    renderBuffer.length,
    hasNextCursor,
    hasPreviousCursor,
    onFetchMore,
    onFetchPrevious,
    ensureRenderBuffer,
    ensureDataBuffer,
    renderStart,
    renderEnd,
    dataStart,
    dataEnd,
  ]);

  // Update buffers when new data arrives
  const updateBuffers = useCallback((newData, startIndex) => {
    setRenderBuffer(prev => {
      const newBuffer = [...prev];
      newData.forEach((item, i) => {
        newBuffer[startIndex + i] = item;
      });
      return newBuffer;
    });
    
    setDataBuffer(prev => {
      const newBuffer = [...prev];
      newData.forEach((item, i) => {
        newBuffer[startIndex + i] = item;
      });
      return newBuffer;
    });
  }, []);

  // Get current visible item
  const currentItem = renderBuffer[currentIndex] || null;

  // Get items for rendering (render buffer)
  const visibleItems = renderBuffer.slice(renderStart, renderEnd + 1);

  // Check if we need to fetch more
  const needsMoreData = currentIndex >= renderBuffer.length - 2;

  return {
    currentItem,
    visibleItems,
    renderBuffer,
    dataBuffer,
    updateBuffers,
    needsMoreData,
    renderStart,
    renderEnd,
    dataStart,
    dataEnd,
  };
}
