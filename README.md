# YMLabel
两种使用方式：
**第一种**
遵守YMLabelDelegate
```
    YMLabel *label = [[YMLabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    
    label.regexStringArray = @[@"《.*?》"];
    NSString *text = @"今天看《西游记》，明天看《三国演义》，后面就是随便写的啦啦啦啦啦啦啦啦啦啦，适合呢么不重要了，最后来个《红楼梦》吧";
    
    // 下面的二选一都可以
    label.text = text;
//    label.attributedText = [[NSAttributedString alloc] initWithString:text];

    // 符合正则表达式的文字颜色
    label.regexTextColor = [UIColor yellowColor];
    // 符合正则表达式的文字 点击时的背景颜色
    label.regexBackgroundColor = [UIColor whiteColor];
    
    label.delegate = self;
    [self.view addSubview:label];
```
实现代理方法
```
- (void)didSelectedOnLabel:(UILabel *)label selectedText:(NSString *)text range:(NSRange)range rangIndex:(NSInteger)index
{
    NSLog(@"选中的文字是:%@ 选中的范围是%@ 第%li个", text, [NSValue valueWithRange:range], (long)index);
}
```

**第二种方法**
初始化方法用`- (instancetype)initWithFrame:(CGRect)frame seletedBlock:(SelectedBlock)block;`
设置属性同第一个方法
示例：
```
YMLabel *label = [[YMLabel alloc] initWithFrame:frame seletedBlock:^(UILabel *label, NSString *text, NSRange range, NSInteger index) {
        NSLog(@"选中的文字是:%@ 选中的范围是%@ 第几个符合的%li", text, [NSValue valueWithRange:range], (long)index);
    }];
```
