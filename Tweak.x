@interface UIScrollView (Adaptive)
@property (nonatomic, assign) BOOL lefty;
@end

@interface _UIScrollViewScrollIndicator : UIView
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) BOOL expandedForDirectManipulation;
+(CGFloat)_expandedIndicatorDimension;
+(CGFloat)indicatorDimension;
@end

%hook UIScrollView
-(void)_scrollViewWillBeginDragging{
	%orig;
	CGPoint location = [self.panGestureRecognizer locationInView:self.superview];
	if(location.x < [UIScreen mainScreen].bounds.size.width/2)
		self.lefty = true;
	else
		self.lefty = false;
}
%new
-(BOOL)lefty{
	return [objc_getAssociatedObject(self, "_lefty") boolValue];
}
%new
-(void)setLefty:(BOOL)lefty{
	objc_setAssociatedObject(self, "_lefty", @(lefty), OBJC_ASSOCIATION_ASSIGN);
	_UIScrollViewScrollIndicator *indicator = [self.subviews lastObject];
    [indicator setFrame:indicator.frame];
}
%end

%hook _UIScrollViewScrollIndicator
-(void)setFrame:(CGRect)frame{
	UIScrollView *scrollView = (UIScrollView *)self.superview;
	if(self.type == 1 && scrollView.lefty){
		if(self.expandedForDirectManipulation)
			frame.origin.x = [%c(_UIScrollViewScrollIndicator) _expandedIndicatorDimension];
		else
			frame.origin.x = [%c(_UIScrollViewScrollIndicator) indicatorDimension];
	}
	%orig;
}
-(void)setExpandedForDirectManipulation:(BOOL)expanded{
	%orig;
	[UIView animateWithDuration:0.1 animations:^(void){
		[self setFrame:self.frame];
	}];
}
%end