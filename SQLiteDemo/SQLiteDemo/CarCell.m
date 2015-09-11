//
//  CarCell.m
//  SQLiteDemo
//
//  Created by ZeluLi on 15/9/10.
//  Copyright (c) 2015年 zeluli. All rights reserved.
//

#import "CarCell.h"
#import "UIImageView+WebCache.h"

@interface CarCell ()
@property (strong, nonatomic) IBOutlet UIImageView *carImageView;
@property (strong, nonatomic) IBOutlet UILabel *carName;

@end

@implementation CarCell

- (void)awakeFromNib {
    // Initialization code
}

-(void) setCellDataWithArray: (NSArray *)data{
    
    NSURL *url = [NSURL URLWithString:data[3]];
    
    NSLog(@"%@", data[3]);
    [self.carImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@""]];
    
    _carName.text = data[1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
