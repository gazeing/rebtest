//
//  SocialShareCell.m
//  HybridWebView
//
//  Created by Steven Xu on 16/07/2014.
//  Copyright (c) 2014 Sterling Publishing. All rights reserved.
//

#import "SocialShareCell.h"

@implementation SocialShareCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // grab bound for contentView
    CGRect contentViewBound = self.contentView.bounds;
    // grab the frame for the imageView
    CGRect imageViewFrame = self.imageView.frame;
    // change x position
    imageViewFrame.origin.x = contentViewBound.size.width - imageViewFrame.size.width;
    // assign the new frame
    self.imageView.frame = imageViewFrame;
    
    CGRect textFrame = self.textLabel.frame;
    textFrame.origin.x = contentViewBound.origin.x;
    textFrame.size.width = contentViewBound.size.width - imageViewFrame.size.width -10;
    self.textLabel.frame = textFrame;
}

@end
