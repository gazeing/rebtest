//
//  PPScrollingTableViewCell.m
//  PPImageScrollingTableViewControllerDemo
//
//  Created by popochess on 13/8/10.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import "PPImageScrollingTableViewCell.h"
#import "PPImageScrollingCellView.h"
#import "Constants.h"


#define kScrollingViewHieght 180
#define kCategoryLabelWidth 200
#define kCategoryLabelHieght 50
#define kStartPointY 50

@interface PPImageScrollingTableViewCell() <PPImageScrollingViewDelegate>

@property (strong,nonatomic) UIColor *categoryTitleColor;
@property(strong, nonatomic) PPImageScrollingCellView *imageScrollingView;
@property (strong, nonatomic) NSString *categoryLabelText;

@end

@implementation PPImageScrollingTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}



- (void)initialize
{
    NSLog(@"pp table view initialize screenwidth = %f",self.frame.size.width);
    
        
    
    // Set ScrollImageTableCellView
    _imageScrollingView = [[PPImageScrollingCellView alloc] initWithFrame:CGRectMake(0., kStartPointY, [self getTableWidth], kScrollingViewHieght)];
    _imageScrollingView.delegate = self;
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
}


- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    
    [_imageScrollingView setFrame:CGRectMake(0., kStartPointY, [self getTableWidth], kScrollingViewHieght)];
//    [_imageScrollingView setColletionViewFrame:CGRectMake(0., kStartPointY, [self getTableWidth], kScrollingViewHieght) ];
}

//-(void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    
//    [_imageScrollingView setFrame:CGRectMake(0., kStartPointY, [self getTableWidth], kScrollingViewHieght)];
//}


- (CGFloat)getTableWidth{
    UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
    if (IS_IPAD) {
        if (UIInterfaceOrientationIsLandscape(orientation)){
            return 1024.;
        }
        else
        {
            return 768.;
        }
    } else if(IS_IPHONE_6)
    {
        return 375.;
    }else if(IS_IPHONE_6_PLUS)
    {
        return 428.;
    }else{
        return 320.;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];    
    // Configure the view for the selected state
}

- (void)setImageData:(NSDictionary*)collectionImageData
{
    [_imageScrollingView setImageData:[collectionImageData objectForKey:@"images"]];
    _categoryLabelText = [collectionImageData objectForKey:@"category"];
}

- (void)setArticleCategory:(ArticleCategory*)collectionImageData
{
    [_imageScrollingView setImageData:collectionImageData.articleList];
    _categoryLabelText = collectionImageData.catName;
}

- (void)setCategoryLabelText:(NSString*)text withColor:(UIColor*)color{
    
    if ([self.contentView subviews]){
        for (UIView *subview in [self.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    UILabel *categoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kCategoryLabelWidth, kCategoryLabelHieght)];
    categoryTitle.textAlignment = NSTextAlignmentLeft;
    categoryTitle.text = text;
    categoryTitle.textColor = color;
    categoryTitle.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:categoryTitle];
}
    
- (void) setImageTitleLabelWitdh:(CGFloat)width withHeight:(CGFloat)height {

    [_imageScrollingView setImageTitleLabelWitdh:width withHeight:height];
}

- (void) setImageTitleTextColor:(UIColor *)textColor withBackgroundColor:(UIColor *)bgColor{

    [_imageScrollingView setImageTitleTextColor:textColor withBackgroundColor:bgColor];
}

- (void)setCollectionViewBackgroundColor:(UIColor *)color{
    
    _imageScrollingView.backgroundColor = color;
    [self.contentView addSubview:_imageScrollingView];
}

#pragma mark - PPImageScrollingViewDelegate

- (void)collectionView:(PPImageScrollingCellView *)collectionView didSelectImageItemAtIndexPath:(NSIndexPath*)indexPath {

    [self.delegate scrollingTableViewCell:self didSelectImageAtIndexPath:indexPath atCategoryRowIndex:self.tag];
}

@end
