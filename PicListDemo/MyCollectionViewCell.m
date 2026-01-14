//
//  MyCollectionViewCell.m
//  PicListDemo
//
//  Created by 李沛林（实习） on 2026/1/13.
//

#import "MyCollectionViewCell.h"
#import <Masonry.h>

@implementation MyCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        [self setupViews];
    }
    return self;
}

-(void)setupViews {
    // 设置cell的背景和圆角
    self.contentView.backgroundColor = [UIColor lightGrayColor];
    self.contentView.layer.cornerRadius = 8;
    self.contentView.clipsToBounds = YES;
    
    // 初始化图片视图
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.layer.cornerRadius = 6;
    //_imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_imageView];
    
    // 添加图片约束
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    
    
    
//    // 初始化文字标签属性
//    _titleLabel = [[UILabel alloc] init];
//    _titleLabel.textAlignment = NSTextAlignmentCenter;
//    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.contentView addSubview:_titleLabel];
    
//    // 添加(创建)约束
//    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.contentView);// 水平居中
//        make.centerY.mas_equalTo(self.contentView);// 垂直居中
//    }];
}

@end

