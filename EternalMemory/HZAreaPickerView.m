//
//  HZAreaPickerView.m
//  areapicker
//
//  Created by Cloud Dai on 12-9-9.
//  Copyright (c) 2012年 clouddai.com. All rights reserved.
//

#import "HZAreaPickerView.h"
#import <QuartzCore/QuartzCore.h>
#import "City.h"
#define kDuration 0.3

@interface HZAreaPickerView ()
{
    NSArray *provinces, *cities, *areas;
}

@end

@implementation HZAreaPickerView

@synthesize delegate=_delegate;
@synthesize pickerStyle=_pickerStyle;
@synthesize locate=_locate;
@synthesize locatePicker = _locatePicker;

- (void)dealloc
{
    [_locate release];
    [_locatePicker release];
    [provinces release];
    [cities release];
    [areas release];
    [super dealloc];
}

-(HZLocation *)locate
{
    if (_locate == nil) {
        _locate = [[HZLocation alloc] init];
    }
    
    return _locate;
}

- (id)initWithStyle:(HZAreaPickerStyle)pickerStyle delegate:(id<HZAreaPickerDelegate>)delegate
{
    self = [[[[NSBundle mainBundle] loadNibNamed:@"HZAreaPickerView" owner:self options:nil] objectAtIndex:0] retain];
    if (self) {
        self.delegate = delegate;
        self.pickerStyle = pickerStyle;
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
        [self locate];
        //加载数据
        if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
            provinces =[[City getProvinceNameAndId] retain];
            cities = [[City getCityForstate:[[[provinces objectAtIndex:0] objectForKey:@"area_id"] integerValue]] retain];
            _locate.state = [provinces objectAtIndex:0];
            _locate.city = [[City getCityForstate:[[[provinces objectAtIndex:0] objectForKey:@"area_id"] integerValue] ] objectAtIndex:0];            
            areas =[[City getDistrictForCity:[[_locate.city objectForKey:@"area_id"] integerValue]] retain];
            if (areas.count > 0) {
                _locate.district = [[areas objectAtIndex:0] retain];
            } else{
                _locate.district = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"title",@"",@"area_id",@"",@"pid",nil];
            }
        } else{
            provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"country.plist" ofType:nil]];
            cities = [[[provinces objectAtIndex:0] objectForKey:@"cities"] retain];
            _locate.state = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[provinces objectAtIndex:0] objectForKey:@"state"],@"title",nil];
            _locate.city = [NSMutableDictionary dictionaryWithObjectsAndKeys:[cities objectAtIndex:0],@"title", nil];
        }
    }
    
    return self;
    
}



#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        return 3;
    } else{
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [provinces count];
            break;
        case 1:
            return [cities count];
            break;
        case 2:
            if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
                return [areas count];
                break;
            }
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict ) {
            switch (component) {
                case 0:
                    return [[provinces objectAtIndex:row] objectForKey:@"title"];
                    break;
                case 1:
                    return [[cities objectAtIndex:row] objectForKey:@"title"];                    break;
                case 2:
                    if ([areas count] > 0) {
                        return [[areas objectAtIndex:row] objectForKey:@"title"];
                        break;
                    }
                default:
                    return  @"";
                    break;
            }
        
    } else{
        switch (component) {
            case 0:
                return [[provinces objectAtIndex:row] objectForKey:@"state"];
                break;
            case 1:
                return [cities objectAtIndex:row];
                break;
            default:
                return @"";
                break;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        switch (component) {
            case 0:
                cities = [[City getCityForstate:[[[provinces objectAtIndex:row] objectForKey:@"area_id"] integerValue]] retain];
                [self.locatePicker selectRow:0 inComponent:1 animated:YES];
                [self.locatePicker reloadComponent:1];
                
                areas = [[City getDistrictForCity:[[[cities objectAtIndex:0] objectForKey:@"area_id"] integerValue]] retain];
                [self.locatePicker selectRow:0 inComponent:2 animated:YES];
                [self.locatePicker reloadComponent:2];
                
                self.locate.state = [provinces objectAtIndex:row];
                self.locate.city = [cities objectAtIndex:0];
                if ([areas count] > 0) {
                    self.locate.district = [areas objectAtIndex:0];
                } else{
                    self.locate.district = [NSMutableDictionary dictionary];
                }
                break;
            case 1:
                areas = [[City getDistrictForCity:[[[cities objectAtIndex:row] objectForKey:@"area_id"] integerValue]] retain];
                [self.locatePicker selectRow:0 inComponent:2 animated:YES];
                [self.locatePicker reloadComponent:2];
                
                self.locate.city = [cities objectAtIndex:row];
                if ([areas count] > 0) {
                    self.locate.district = [areas objectAtIndex:0];
                } else{
                    self.locate.district = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"title",@"",@"area_id", nil];
                }
                break;
            case 2:
                if ([areas count] > 0) {
                    self.locate.district = [areas objectAtIndex:row];
                } else{
                    self.locate.district = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"title",@"",@"area_id", nil];
                }
                break;
            default:
                break;
        }
    } else{
        switch (component) {
            case 0:
                cities = [[[provinces objectAtIndex:row] objectForKey:@"cities"] retain];
                [self.locatePicker selectRow:0 inComponent:1 animated:YES];
                [self.locatePicker reloadComponent:1];
                
                self.locate.state = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[provinces objectAtIndex:row] objectForKey:@"state"],@"title", nil];
                self.locate.city = [NSMutableDictionary dictionaryWithObjectsAndKeys:[cities objectAtIndex:0],@"title", nil];
                break;
            case 1:
                self.locate.city = [NSMutableDictionary dictionaryWithObjectsAndKeys:[cities objectAtIndex:row],@"title", nil];
                break;
            default:
                break;
        }
    }
    
    if([self.delegate respondsToSelector:@selector(pickerDidChaneStatus:)]) {
        [self.delegate pickerDidChaneStatus:self];
    }
    
}


#pragma mark - animation

- (void)showInView:(UIView *) view
{
    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
    
}

- (void)cancelPicker
{
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         
                     }];
    
}

@end
