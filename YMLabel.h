//
//  YMLabel.h
//  Demo
//
//  Created by 张艳明 on 2018/7/5.
//  Copyright © 2018年 张艳明. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMLabelDelegate <NSObject>
- (void)didSelectedOnLabel:(UILabel *)label selectedText:(NSString *)text range:(NSRange)range rangIndex:(NSInteger)index;
@end

// ⚠️ 现在默认必须设置sizeToFit 否则点击位置确定不准确

typedef void(^SelectedBlock)(UILabel *label, NSString *text, NSRange range, NSInteger index);
@interface YMLabel : UILabel

/** 正则表达式数组 匹配需要添加点击事件的文字 */
@property (nonatomic, copy) NSArray *regexStringArray;
/** 符合正则判断的文字颜色 */
@property (nonatomic, strong) UIColor *regexTextColor;
/** 点击符合正则判断的文字 显示的背景颜色 默认是空的 */
@property (nonatomic, strong) UIColor *regexBackgroundColor;

// 下面两个方式 可以二选一
@property (nonatomic, weak) id <YMLabelDelegate> delegate;
@property (nonatomic, copy) SelectedBlock block;


- (instancetype)initWithFrame:(CGRect)frame seletedBlock:(SelectedBlock)block;

@end
