import React, { useRef, useState, useCallback, useEffect } from 'react';
import {
  View,
  Dimensions,
  StyleSheet,
  StatusBar,
} from 'react-native';
import { FlashList } from '@shopify/flash-list';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const { width, height } = Dimensions.get('window');

export function PagedList({
  data = [],
  index = 0,
  onIndexChange,
  onNearEnd,
  renderItem,
  cardHeight,
  ...props
}) {
  const insets = useSafeAreaInsets();
  const listRef = useRef(null);
  const [currentIndex, setCurrentIndex] = useState(index);
  
  // Calculate card height to fill screen minus safe areas, then reduce by 20%
  const baseCardHeight = cardHeight || (height - insets.top - insets.bottom);
  const effectiveCardHeight = baseCardHeight;
  // const cardSpacing = 40; // Spacing between cards
  // const totalItemHeight = effectiveCardHeight + cardSpacing; // Total height including spacing
  
  // Handle index changes
  const handleIndexChange = useCallback((newIndex) => {
    if (newIndex !== currentIndex) {
      setCurrentIndex(newIndex);
      onIndexChange?.(newIndex);
      
      // Trigger near end callback when reaching second-to-last item
      if (newIndex >= data.length - 2) {
        onNearEnd?.(newIndex);
      }
    }
  }, [currentIndex, data.length, onIndexChange, onNearEnd]);

  // Snap to specific index
  const snapToIndex = useCallback((targetIndex) => {
    if (listRef.current && targetIndex >= 0 && targetIndex < data.length) {
      listRef.current.scrollToIndex({
        index: targetIndex,
        animated: true,
      });
    }
  }, [data.length]);

  // Handle viewable items change
  const handleViewableItemsChanged = useCallback(({ viewableItems }) => {
    if (viewableItems.length > 0) {
      const visibleIndex = viewableItems[0].index;
      handleIndexChange(visibleIndex);
    }
  }, [handleIndexChange]);

  // Sync with external index changes
  useEffect(() => {
    if (index !== currentIndex) {
      snapToIndex(index);
    }
  }, [index, currentIndex, snapToIndex]);

  // Render item wrapper
  const renderItemWrapper = useCallback(({ item, index: itemIndex }) => {
    return (
      <View style={[styles.cardContainer, { height: effectiveCardHeight }]}>
        {renderItem(item, itemIndex)}
      </View>
    );
  }, [renderItem, effectiveCardHeight]);

  // Get item layout for better performance
  const getItemLayout = useCallback((data, index) => ({
    length: effectiveCardHeight,
    offset: effectiveCardHeight * index,
    index,
  }), [effectiveCardHeight]);

  return (
    <View style={styles.container}>
      <FlashList
        ref={listRef}
        data={data}
        renderItem={renderItemWrapper}
        estimatedItemSize={effectiveCardHeight}
        getItemLayout={getItemLayout}
        onViewableItemsChanged={handleViewableItemsChanged}
        viewabilityConfig={{
          itemVisiblePercentThreshold: 50,
          minimumViewTime: 100,
        }}
        pagingEnabled={true}
        snapToInterval={effectiveCardHeight}
        decelerationRate="fast"
        removeClippedSubviews={true}
        windowSize={5}
        maxToRenderPerBatch={3}
        initialScrollIndex={index}
        showsVerticalScrollIndicator={false}
        showsHorizontalScrollIndicator={false}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        {...props}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  itemWrapper: {
    width,
    justifyContent: 'space-between',
  },
  cardContainer: {
    width,
    justifyContent: 'center',
    alignItems: 'center',
    paddingBottom: 100,
  },
});
