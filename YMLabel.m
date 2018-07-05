//
//  YMLabel.m
//  Demo
//
//  Created by 张艳明 on 2018/7/5.
//  Copyright © 2018年 张艳明. All rights reserved.
//

#import "YMLabel.h"

@interface YMLabel ()

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

/** 符合正则表达式的文字range数组 以NSValue保存 */
@property (nonatomic, strong) NSMutableArray <NSValue *>*regexResultRanges;
/** 当前选中的文字范围 */
@property (nonatomic, assign) NSRange selectedRange;

/** 点击符合正则的文字 背景颜色 默认是label的背景颜色 */
@property (nonatomic, strong) UIColor *selectedBackgroundColor;

@end

@implementation YMLabel

- (UIColor *)selectedBackgroundColor
{
    if (self.regexBackgroundColor == nil) {
        return self.backgroundColor;
    }
    return self.regexBackgroundColor;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame seletedBlock:(SelectedBlock)block
{
    self = [self initWithFrame:frame];
    self.block = block;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupData];
    }
    return self;
}

- (void)setupData
{
    self.regexStringArray = @[];
    self.regexTextColor = [UIColor orangeColor];
    self.regexResultRanges = [NSMutableArray array];
    
    NSTextStorage *storage = [[NSTextStorage alloc] init];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    
    [storage addLayoutManager:layoutManager];
    [layoutManager addTextContainer:container];
    
    self.textStorage = storage;
    self.layoutManager = layoutManager;
    self.textContainer = container;
    
    self.textContainer.lineFragmentPadding = 0;
    self.userInteractionEnabled = YES;
}

#pragma mark - 重写属性赋值方法
- (void)setText:(NSString *)text
{
    [super setText:text];
    self.attributedText = [[NSAttributedString alloc] initWithString:text];
    [self updateTextStorage];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self updateTextStorage];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self updateTextStorage];
}

- (void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];
    [self updateTextStorage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textContainer.size = self.bounds.size;
}

#pragma mark - 绘制符合条件的文字
- (void)drawRect:(CGRect)rect
{
    NSRange range = [self glyhsRange];
    CGPoint offset = [self glyphsOffset:range];
    
    [self.layoutManager drawBackgroundForGlyphRange:range atPoint:offset];
    [self.layoutManager drawGlyphsForGlyphRange:range atPoint:offset];
}

- (NSRange)glyhsRange
{
    return NSMakeRange(0, self.textStorage.string.length);
}

- (CGPoint)glyphsOffset:(NSRange)range
{
    CGRect rect = [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer];
    // 这里是写死的 必须sizeToFit才行 如果有底部有留白 height计算方式是错的
    CGFloat height = (self.bounds.size.height - rect.size.height) * 0.5;
    return CGPointMake(0, height);
}

- (void)updateTextStorage
{
    if (self.attributedText == nil) { return; }
    
    NSMutableAttributedString *mutaAttriString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [self regexLinkRanges:mutaAttriString];
    [self addRegexTextAttribute:mutaAttriString];
    
    [self.textStorage setAttributedString:mutaAttriString];
    [self setNeedsDisplay];

    [self sizeToFit];
}

// 给属性字符串设置属性
- (void)addRegexTextAttribute:(NSMutableAttributedString *)mutaAttriString
{
    if (mutaAttriString.length == 0) { return; }
    
    NSRange range = NSMakeRange(0, 0);
    NSMutableDictionary *attriDict = [NSMutableDictionary dictionaryWithDictionary:[mutaAttriString attributesAtIndex:0 effectiveRange:&range]];
    
    attriDict[NSFontAttributeName] = self.font;
    attriDict[NSForegroundColorAttributeName] = self.textColor;
    [mutaAttriString addAttributes:attriDict range:range];
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    attriDict[NSParagraphStyleAttributeName] = paragraphStyle;
    
    attriDict[NSForegroundColorAttributeName] = self.regexTextColor;
    for (NSValue *resultValue in self.regexResultRanges) {
        [mutaAttriString setAttributes:attriDict range:resultValue.rangeValue];
    }
}

#pragma mark - 正则判断
- (void)regexLinkRanges:(NSAttributedString *)attriString
{
    if (self.regexStringArray.count == 0) { return; }
    
    [self.regexResultRanges removeAllObjects];
    
    NSRange regexRange = NSMakeRange(0, attriString.length);
    for (NSString *pattern in self.regexStringArray) {
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:nil];
        NSArray *results = [regex matchesInString:attriString.string options:NSMatchingReportProgress range:regexRange];
        
        for (NSTextCheckingResult *r in results) {
            NSValue *rangeValue = [NSValue valueWithRange:r.range];
            [self.regexResultRanges addObject:rangeValue];
        }
    }
}

#pragma mark - 点击事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [touches.anyObject locationInView:self];
    self.selectedRange = [self rangeAtLocation:location];
    [self modifySelectedAttribute:YES];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [touches.anyObject locationInView:self];
    
    NSRange range = [self rangeAtLocation:location];
    if (range.location != NSNotFound) {
        if (!(range.location == self.selectedRange.location && range.length == self.selectedRange.length)) {
            [self modifySelectedAttribute:NO];
            self.selectedRange = range;
            [self modifySelectedAttribute:YES];
        }
    } else {
        [self modifySelectedAttribute:NO];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.selectedRange.location != NSNotFound) {
        
        NSString *text = [self.textStorage.string substringWithRange:self.selectedRange];
        NSValue *value = [NSValue valueWithRange:self.selectedRange];
        NSInteger index = [self.regexResultRanges indexOfObject:value];
        if ([self.delegate respondsToSelector:@selector(didSelectedOnLabel:selectedText:range:rangIndex:)]) {
            [self.delegate didSelectedOnLabel:self selectedText:text range:self.selectedRange rangIndex:index];
        } else if (self.block) {
            self.block(self, text, self.selectedRange, index);
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self modifySelectedAttribute:NO];
        });
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self modifySelectedAttribute:NO];
}

// 更新选中符合正则文字的背景颜色
- (void)modifySelectedAttribute:(BOOL)isSet
{
    if (self.selectedRange.location == NSNotFound) { return; }
    
    NSMutableDictionary *attriDict = [NSMutableDictionary dictionaryWithDictionary:[self.textStorage attributesAtIndex:0 effectiveRange:nil]];
    NSRange range = self.selectedRange;
    if (isSet) {
        attriDict[NSBackgroundColorAttributeName] = self.selectedBackgroundColor;
    } else {
        attriDict[NSBackgroundColorAttributeName] = [UIColor clearColor];
        self.selectedRange = NSMakeRange(NSNotFound, 0);
    }
    attriDict[NSForegroundColorAttributeName] = self.regexTextColor;
    [self.textStorage addAttributes:attriDict range:range];
    [self setNeedsDisplay];
}

// 查看点击的point是否在正则匹配的range中
- (NSRange)rangeAtLocation:(CGPoint)location
{
    if (self.textStorage.length == 0) { return NSMakeRange(NSNotFound, 0); };
    
//    CGPoint offset = [self glyphsOffset:[self glyhsRange]];
//    CGPoint point = CGPointMake(offset.x + location.x, offset.y + location.y);
    NSInteger index = [self.layoutManager glyphIndexForPoint:location inTextContainer:self.textContainer];
    for (NSValue *rangeValue in self.regexResultRanges) {
        NSRange range = rangeValue.rangeValue;
        if (index >= range.location && index < range.location + range.length) {
            return range;
        }
    }
    return NSMakeRange(NSNotFound, 0);
}

@end







