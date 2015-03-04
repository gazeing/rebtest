//
//  TopStoryView.m
//  RPM
//
//  Created by Steven Xu on 12/02/2015.
//  Copyright (c) 2015 Sterling Publishing. All rights reserved.
//

#import "TopStoryView.h"
#import "Article.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"



@interface TopStoryView()


@property (strong, nonatomic) UIImageView *headImageView;
@property (strong, nonatomic) UILabel *headLabelView;
@property (strong, nonatomic) UILabel *headIntroTextLabelView;
@property (strong, nonatomic) UILabel *headReadMoreLabelView;

@property (strong, nonatomic) UIView  *lineViewBottom;

@end


@implementation TopStoryView



#pragma mark - Initalization
- (id)  init
{
    return [self initWithFrame:CGRectMake(0, 0, PORTRAIT_IPAD_WIDTH, TOP_STORY_IMAGE_SIZE + TOP_STORY_PADDING_TOP*2 )];
}

- (id)initWithFrame:(CGRect)frame //code
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder { //XIB
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createUI];
    }
    return self;
}
- (void) createUI {
    
    
    //main color
    UIColor *maincolor = [UIColor colorWithRed:37.0/255.0 green:170.0/255.0 blue:226.0/255.0 alpha:1];
    
    //add image view
    
    self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(TOP_STORY_PADDING_LEFT, TOP_STORY_PADDING_TOP, TOP_STORY_IMAGE_SIZE, TOP_STORY_IMAGE_SIZE)];
    [self addSubview:self.headImageView];
    
    //add title view
    
    self.headLabelView = [[UILabel alloc] initWithFrame:CGRectMake(TOP_STORY_PADDING_TOP + TOP_STORY_PADDING_LEFT + TOP_STORY_IMAGE_SIZE , TOP_STORY_PADDING_TOP, PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE -TOP_STORY_PADDING_TOP * 2- TOP_STORY_PADDING_LEFT, TOP_STORY_PADDING_TOP)];
    self.headLabelView.numberOfLines = 0; //will wrap text in new line
    //    self.headLabelView.textAlignment = NSTextAlignmentCenter;
    [self.headLabelView setFont:[UIFont fontWithName:@"Helvetica-Bold" size:39]];
    [self.headLabelView setTextColor:maincolor];
    [self addSubview:self.headLabelView];
    
    //add top line
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(TOP_STORY_PADDING_TOP + TOP_STORY_PADDING_LEFT  + TOP_STORY_IMAGE_SIZE , TOP_STORY_PADDING_TOP, PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE -TOP_STORY_PADDING_TOP * 2- TOP_STORY_PADDING_LEFT, 1)];
    lineView.backgroundColor = maincolor;
    [self addSubview:lineView];
    
    //add intro text.
    
    self.headIntroTextLabelView = [[UILabel alloc] initWithFrame:CGRectMake(TOP_STORY_PADDING_TOP  + TOP_STORY_PADDING_LEFT+ TOP_STORY_IMAGE_SIZE , TOP_STORY_PADDING_TOP*3, PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE - TOP_STORY_PADDING_TOP * 2 - TOP_STORY_PADDING_LEFT, TOP_STORY_IMAGE_SIZE - TOP_STORY_PADDING_TOP * 2)];
    self.headIntroTextLabelView.numberOfLines = 0;
    [self.headIntroTextLabelView setFont:[UIFont fontWithName:@"Helvetica" size:25]];
    [self.headIntroTextLabelView setTextColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:32.0/255.0 alpha:1]];
    [self addSubview:self.headIntroTextLabelView];
    
    //add "read more" label
    self.headReadMoreLabelView  = [[UILabel alloc] initWithFrame:CGRectMake(TOP_STORY_PADDING_TOP + TOP_STORY_PADDING_LEFT + TOP_STORY_IMAGE_SIZE , TOP_STORY_PADDING_TOP*4, PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE -TOP_STORY_PADDING_TOP * 2- TOP_STORY_PADDING_LEFT, TOP_STORY_PADDING_TOP)];
    self.headReadMoreLabelView.numberOfLines = 0; //will wrap text in new line
    self.headReadMoreLabelView.textAlignment = NSTextAlignmentRight;
    [self.headReadMoreLabelView setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [self.headReadMoreLabelView setTextColor:maincolor];
    
    [self addSubview:self.headReadMoreLabelView];
    
    //add bottom line
    
    self.lineViewBottom = [[UIView alloc] initWithFrame:CGRectMake(TOP_STORY_PADDING_TOP + TOP_STORY_PADDING_LEFT + TOP_STORY_IMAGE_SIZE , TOP_STORY_PADDING_TOP+ TOP_STORY_IMAGE_SIZE, PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE -TOP_STORY_PADDING_TOP * 2- TOP_STORY_PADDING_LEFT, 1)];
    self.lineViewBottom.backgroundColor = maincolor;
    [self addSubview:self.lineViewBottom];
    
    [self setBackgroundColor:[UIColor clearColor]];
   

}

- (void)resizeView
{
    
    CGRect titleRect = self.headLabelView.frame;
    
    CGFloat totalHeight = titleRect.size.height + self.headIntroTextLabelView.frame.size.height + TOP_STORY_PADDING_TOP*1.5 + self.headReadMoreLabelView.frame.size.height;
    
    if (totalHeight <= TOP_STORY_IMAGE_SIZE)
    {
        [self.headLabelView setFrame:CGRectMake(TOP_STORY_PADDING_TOP + TOP_STORY_PADDING_LEFT + TOP_STORY_IMAGE_SIZE , TOP_STORY_PADDING_TOP + (TOP_STORY_IMAGE_SIZE - totalHeight) /2 , PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE - TOP_STORY_PADDING_TOP * 2 - TOP_STORY_PADDING_LEFT, titleRect.size.height)];
        [self.headIntroTextLabelView setFrame:CGRectMake(TOP_STORY_PADDING_TOP * 1 + TOP_STORY_PADDING_LEFT + TOP_STORY_IMAGE_SIZE , TOP_STORY_PADDING_TOP/2 + TOP_STORY_PADDING_TOP + (TOP_STORY_IMAGE_SIZE - totalHeight) /2 + titleRect.size.height, PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE - TOP_STORY_PADDING_TOP * 2 - TOP_STORY_PADDING_LEFT, self.headIntroTextLabelView.frame.size.height)];
        [self.headReadMoreLabelView setFrame:CGRectMake(TOP_STORY_PADDING_TOP * 1 + TOP_STORY_PADDING_LEFT + TOP_STORY_IMAGE_SIZE ,  TOP_STORY_PADDING_TOP*2 + (TOP_STORY_IMAGE_SIZE - totalHeight) /2 + titleRect.size.height+ self.headIntroTextLabelView.frame.size.height, PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE - TOP_STORY_PADDING_TOP * 2 - TOP_STORY_PADDING_LEFT, self.headReadMoreLabelView.frame.size.height)];
    } else
    {
        [self setFrame:CGRectMake(0, 0, PORTRAIT_IPAD_WIDTH, TOP_STORY_PADDING_TOP*2 +  totalHeight )];
        [self.headImageView setFrame:CGRectMake(TOP_STORY_PADDING_LEFT, TOP_STORY_PADDING_TOP + (totalHeight - TOP_STORY_IMAGE_SIZE) / 2, TOP_STORY_IMAGE_SIZE, TOP_STORY_IMAGE_SIZE)];
        [self.headLabelView setFrame:CGRectMake(TOP_STORY_PADDING_TOP * 1 + TOP_STORY_PADDING_LEFT + TOP_STORY_IMAGE_SIZE , TOP_STORY_PADDING_TOP , PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE - TOP_STORY_PADDING_TOP * 2 - TOP_STORY_PADDING_LEFT, titleRect.size.height)];
        [self.headIntroTextLabelView setFrame:CGRectMake(TOP_STORY_PADDING_TOP * 1 + TOP_STORY_PADDING_LEFT+ TOP_STORY_IMAGE_SIZE , TOP_STORY_PADDING_TOP/2 + TOP_STORY_PADDING_TOP + titleRect.size.height , PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE - TOP_STORY_PADDING_TOP * 2- TOP_STORY_PADDING_LEFT, self.headIntroTextLabelView.frame.size.height)];
        [self.headReadMoreLabelView setFrame:CGRectMake(TOP_STORY_PADDING_TOP * 1 + TOP_STORY_PADDING_LEFT + TOP_STORY_IMAGE_SIZE ,  + TOP_STORY_PADDING_TOP *2 + titleRect.size.height+ self.headIntroTextLabelView.frame.size.height, PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE - TOP_STORY_PADDING_TOP * 2 - TOP_STORY_PADDING_LEFT, self.headReadMoreLabelView.frame.size.height)];
        [self.lineViewBottom setFrame:CGRectMake(TOP_STORY_PADDING_TOP * 1 + TOP_STORY_PADDING_LEFT + TOP_STORY_IMAGE_SIZE ,  TOP_STORY_PADDING_TOP*2 +  totalHeight, PORTRAIT_IPAD_WIDTH - TOP_STORY_IMAGE_SIZE - TOP_STORY_PADDING_TOP * 2 - TOP_STORY_PADDING_LEFT, 1)];
        
        
    }

    
}

- (void)fillWithFirstArticle:(Article *)article
{
    
    
    self.headLabelView.text = article.title;
    
    [self.headLabelView sizeToFit];
    
    self.headIntroTextLabelView.text = [self stringByStrippingHTML:article.introtext];
    
    
    [self.headIntroTextLabelView sizeToFit];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.headReadMoreLabelView.attributedText = [[NSAttributedString alloc] initWithString:@"READ MORE" attributes:underlineAttribute];
    
    
    [self resizeView];
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:article.image]
                          placeholderImage:[UIImage imageNamed:@"logos2.png"]];
    
}

-(NSString *) stringByStrippingHTML : (NSString *) html
{
    NSRange r;
    NSString *s = [html copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
// Drawing code
}
*/

@end
