//
//  OtherMemberHeaderDetailView.m
//  EternalMemory
//
//  Created by Liu Zhuang on 13-10-16.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "OtherMemberHeaderDetailView.h"
#import "GenealogyMetaData.h"
#import "Utilities.h"
#import "MyFamilySQL.h"
@interface OtherMemberHeaderDetailView ()

@property (nonatomic, assign) IBOutlet UILabel *birthAndDeathLabel;
@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet UILabel *identityLabel;
@property (nonatomic, assign) IBOutlet UILabel *motherLabel;
@property (nonatomic, assign) IBOutlet UILabel *parentTypeLabel;

@property (nonatomic, retain) NSDictionary *memberInfo;

@end

@implementation OtherMemberHeaderDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithNib
{
    self = [super init];
    if (self) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"OtherMemberHeaderDetailView" owner:nil options:nil];
        for (id obj in views) {
            if ([obj isKindOfClass:[OtherMemberHeaderDetailView class]]) {
                self = (OtherMemberHeaderDetailView *)obj;
            }
        }
    }
    
    return self;
}

- (void)configData:(NSDictionary *)data andParentType:(NSString *)type
{
    if (_memberInfo != data) {
        [_memberInfo release];
        _memberInfo = [data retain];
    }
    
    BOOL isDead = [_memberInfo[kIsDead] boolValue];
    NSString *dateFormat = @"yyyy.MM.dd";
    NSString *birthDate = [Utilities convertTimestempToDateWithString:_memberInfo[kBirthDate] andDateFormat:dateFormat];
    NSString *deathDate = [Utilities convertTimestempToDateWithString:_memberInfo[kDeathDate] andDateFormat:dateFormat];
    
    if (isDead) {
        _birthAndDeathLabel.text = [NSString stringWithFormat:@"%@ — %@", birthDate, deathDate];
    } else {
        _birthAndDeathLabel.text = [NSString stringWithFormat:@"%@ - ",birthDate];
    }
    
    
    NSDictionary *motherInfo = [[MyFamilySQL getMotherInfoWithMotherId:_memberInfo[kMotherID] andMemberId:_memberInfo[kMemberId]] copy];
    
    _parentTypeLabel.text = type;
    
    NSString *parentId = _memberInfo[kParentId];
    _motherLabel.text = motherInfo[kName];
    if (_motherLabel.text.length == 0 || [parentId isEqualToString:@""]) {
        _motherLabel.text = @"未知";
    }
    _titleLabel.text = _memberInfo[kNickName];
    _identityLabel.text = _memberInfo[kSubTitle];

    if (_identityLabel.text.length == 0) {
        _identityLabel.text = @"未知";
    }

    
    [motherInfo release];
    
}


- (void)dealloc
{
    [self setBirthAndDeathLabel:nil];
    [self setTitleLabel:nil];
    [self setMotherLabel:nil];
    [self setIdentityLabel:nil];
    [_memberInfo release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
