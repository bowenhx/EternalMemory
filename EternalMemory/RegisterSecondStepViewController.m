//
//  RegisterSecondStepViewController.m
//  EternalMemory
//
//  Created by sun on 13-5-20.
//  Copyright (c) 2013年 sun. All rights reserved.
//

#import "RegisterSecondStepViewController.h"
#import "LoginViewController.h"
#import "RequestParams.h"
#import "MD5.h"
#import "MyToast.h"
#import "ServiceContactViewController.h"
#define REQUEST_FOR_REGISTER   100
#define IPHONE4                [[UIDevice currentDevice].systemVersion integerValue]<6.0

@interface RegisterSecondStepViewController ()


- (IBAction)clickServiceContactBtn:(id)sender;
@property (nonatomic, retain) IBOutlet UITextField *phoneNumberTF;
@property (nonatomic, retain) IBOutlet UITextField *inviterPhoneNumberTF;
@property (nonatomic, retain) IBOutlet UITextField *addressDetailTF;
@property (nonatomic, retain) IBOutlet UIImageView *checkmarkImgView;
@property (nonatomic, retain) IBOutlet UILabel *countryLb;
@property (nonatomic, retain) IBOutlet UILabel *areaLb;
@property (nonatomic, retain) IBOutlet UIButton *checkmarkbtn;
@property (nonatomic, retain) IBOutlet UIButton *areaBtn;
@property (retain, nonatomic) IBOutlet UITextField *foreignCityName;
@property (retain, nonatomic) IBOutlet UIImageView *cityArrow;
@property (nonatomic, retain) NSString *areaValue, *cityValue;
@property (nonatomic, retain) NSMutableString *addressString;
@property (nonatomic, retain) HZAreaPickerView *locatePicker;
@property (nonatomic, assign) BOOL isChecked;

- (IBAction)onCountryStateBtnClicked;
- (IBAction)onCityRegionBtnClicked;
- (IBAction)onRegisterBtnClicked;
- (IBAction)onAgreementBtnClicked;
- (void)cancelLocatePicker;
- (void)registeRequest;
@end

@implementation RegisterSecondStepViewController
@synthesize phoneNumberTF = _phoneNumberTF;
@synthesize inviterPhoneNumberTF = _inviterPhoneNumberTF;
@synthesize addressDetailTF = _addressDetailTF;
@synthesize checkmarkImgView = _checkmarkImgView;
@synthesize checkmarkbtn = _checkmarkbtn;
@synthesize countryLb = _countryLb;
@synthesize areaLb = _areaLb;
@synthesize locatePicker = _locatePicker;
@synthesize areaValue = _areaValue;
@synthesize cityValue = _cityValue;
@synthesize isChecked = _isChecked;
@synthesize dataDictionary = _dataDictionary;
@synthesize addressString = _addressString;
@synthesize areaBtn = _areaBtn;
#pragma mark - object lifecycle
- (void)dealloc
{
    RELEASE_SAFELY(_phoneNumberTF);
    RELEASE_SAFELY(_inviterPhoneNumberTF);
    RELEASE_SAFELY(_checkmarkImgView);
    RELEASE_SAFELY(_checkmarkbtn);
    RELEASE_SAFELY(_areaLb);
    RELEASE_SAFELY(_countryLb);
    RELEASE_SAFELY(_cityValue);
    RELEASE_SAFELY(_areaValue);
    RELEASE_SAFELY(_locatePicker);
    RELEASE_SAFELY(_dataDictionary);
    RELEASE_SAFELY(_addressString);
    RELEASE_SAFELY(_areaBtn);
    [_foreignCityName release];
    [_cityArrow release];
    [super dealloc];
}
-(void)setAreaValue:(NSString *)areaValue
{
    if ([areaValue hasPrefix:@"(null)"])
    {
        areaValue = [areaValue stringByReplacingOccurrencesOfString:@"(null)" withString:@"北京"];
    }
    
    if (![_areaValue isEqualToString:areaValue]) {
        _areaValue = [areaValue retain];
        self.areaLb.text = areaValue;
    }
}

-(void)setCityValue:(NSString *)countryValue
{
    if (![_cityValue isEqualToString:countryValue]) {
        _cityValue = [countryValue retain];
        self.countryLb.text = countryValue;
    }
}

- (void)viewDidUnload
{
    [self cancelLocatePicker];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isChecked = YES;
        _dataDictionary = [[NSDictionary alloc] init];
        _addressString = [[NSMutableString alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setViewData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
- (void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setViewData
{
    // nevBar
    self.middleBtn.hidden = YES;
    self.titleLabel.text = @"用户注册";
    self.rightBtn.hidden = YES;
    //TextField
    UIColor *_color = RGBCOLOR(118,131,141);
    if (IPHONE4) {
        _phoneNumberTF.placeholder=@"手机号码（选填）";
        _inviterPhoneNumberTF.placeholder=@"邀请人号码（选填）";
        _addressDetailTF.placeholder=@"详细地址";
    }else{
        _phoneNumberTF.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"手机号码（选填）" attributes:@{NSForegroundColorAttributeName: _color}]  autorelease];
        _inviterPhoneNumberTF.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"邀请人号码（选填）" attributes:@{NSForegroundColorAttributeName: _color}]  autorelease];
        _addressDetailTF.attributedPlaceholder = [[[NSAttributedString alloc] initWithString:@"详细地址" attributes:@{NSForegroundColorAttributeName: _color}] autorelease];
    }
    
    //_checkmarkbtn
    _checkmarkbtn.selected = YES;
}
- (void)registeRequest
{
//    NSLog(@"#######_dataDictionary = %@",_dataDictionary);
    NSURL *registerUrl = [[RequestParams sharedInstance] userRegister1];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:registerUrl];
    request.delegate = self;
    request.shouldAttemptPersistentConnection = NO;
    request.userInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:REQUEST_FOR_REGISTER],@"tag", nil]  ;
   
    [request setPostValue:[_dataDictionary objectForKey:@"userName"] forKey:@"username"];
    [request setPostValue:[MD5 md5:[_dataDictionary objectForKey:@"passWord"]] forKey:@"password"];
    [request setPostValue:[_dataDictionary objectForKey:@"tureName"] forKey:@"realname"];
    [request setPostValue:[_dataDictionary objectForKey:@"peopleNumber"] forKey:@"sid"];
    [request setPostValue:_dataDictionary[@"birth"] forKey:@"birthdate"];
    [request setPostValue:_dataDictionary[@"sex"] forKey:@"sex"];
    [request setPostValue:_addressString forKey:@"addressdetail"];
    [request setPostValue:[NSNumber numberWithInt:countryID] forKey:@"countryid"];
    [request setPostValue:[NSNumber numberWithInt:provinceID] forKey:@"provinceid"];
    [request setPostValue:[NSNumber numberWithInt:cityID] forKey:@"cityid"];
    [request setPostValue:[NSNumber numberWithInt:districtID] forKey:@"districtid"];
    if (_phoneNumberTF.text.length != 0) {
        [request setPostValue:_phoneNumberTF.text forKey:@"mobile"];
    }
    if (_inviterPhoneNumberTF.text.length != 0) {
        [request setPostValue:_inviterPhoneNumberTF.text forKey:@"guidetel"];
    }
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:10.0];
    __block typeof (self) bself=self;

    [request setCompletionBlock:^{
        [bself requestSuccess:request];
    }];
    [request setFailedBlock:^{
        [bself requestFail:request];
    }];
    [request startAsynchronous];
   
}

#pragma mark - IBAction methods,public methods
- (IBAction)textFieldResignFirstResponder
{
    [self cancelLocatePicker];
    NSArray *viewsArray = [[self view] subviews];
    
    for (UIView *subView in viewsArray) {
        
        if ([subView isKindOfClass:[UITextField class]]) {
            
            [subView resignFirstResponder];
        }
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect frame = self.view .frame;
                         frame.origin.y = 0 ;
                         self.view.frame = frame;
                     }];
    
}
- (IBAction)onCountryStateBtnClicked
{
    [self textFieldResignFirstResponder];
    if (!self.locatePicker && [self.countryLb.text hasPrefix:@"国家"])
    {
        self.locatePicker = [[[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCity delegate:self] autorelease];
        [self.locatePicker showInView:self.view];
        self.countryLb.text = @"中国";
    }
    else if (!self.locatePicker)
    {
        self.locatePicker = [[[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCity delegate:self] autorelease];
        [self.locatePicker showInView:self.view];
    }
    else if (self.locatePicker.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict)
    {
        [self textFieldResignFirstResponder];
        self.locatePicker = [[[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCity delegate:self] autorelease];
        [self.locatePicker showInView:self.view];
    }
    else
    {
        return;
    }
    
}
- (IBAction)onCityRegionBtnClicked
{
    if ([_countryLb.text isEqualToString:@"国家"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请先选择国家" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        [alertView release];
    }
    else if ([_countryLb.text hasPrefix:@"中国"])
    {
        countryID = 86;
        if (self.locatePicker.pickerStyle == HZAreaPickerWithStateAndCity)
        {
            [self textFieldResignFirstResponder];
            self.locatePicker = [[[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCityAndDistrict delegate:self] autorelease];
            [self.locatePicker showInView:self.view];
        }
        else
        {
            return;
        }
        
    }
}
- (IBAction)onRegisterBtnClicked
{
    if (!_isChecked) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请仔细阅读《永恒记忆使用协议》，并同意" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    } else {
//        _addressString = [NSMutableString stringWithString:@""];
        
        if (![_countryLb.text isEqualToString:@"国家"])
        {
            [_addressString appendString:_countryLb.text];
        }
        else if ([_countryLb.text hasPrefix:@"国外"])
        {            
            [_addressString appendString:_foreignCityName.text];
        }
        
        if ([_countryLb.text hasPrefix:@"中国"])
        {
            if (![_areaLb.text isEqualToString:@"省市地区"]) {
                [_addressString appendString:_areaLb.text];
            }
        }
        
        if (_addressDetailTF.text.length != 0) {
            [_addressString appendString:_addressDetailTF.text];
        }
                
        if ([_addressString isEqualToString:@"中国省市地区"] || [_addressString isEqualToString:@""]) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请填写地址" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            return;
        }
        NSString *mobilephoneRegex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0-2,5-9]))\\d{8}$";//验证手机号是否正确
        if (_phoneNumberTF.text.length != 0) {
            NSPredicate *mobilePhonePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobilephoneRegex];
            BOOL mobileIsMatch = [mobilePhonePred evaluateWithObject:_phoneNumberTF.text];
            if (!mobileIsMatch) {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请填写正确的手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alert.tag = 2000;
                [alert show];
                [alert release];
                return;
            }
        }
        if (_inviterPhoneNumberTF.text.length != 0) {
            NSPredicate *mobilePhonePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobilephoneRegex];
            BOOL mobileIsMatch = [mobilePhonePred evaluateWithObject:_inviterPhoneNumberTF.text];
            if (!mobileIsMatch) {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请填写正确的手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alert.tag = 2000;
                [alert show];
                [alert release];
                return;
            }
        }

        [self registeRequest];
        
    }
}
- (IBAction)onAgreementBtnClicked
{
    _checkmarkbtn.selected=!_checkmarkbtn.selected;
    if (_checkmarkbtn.selected) {
        _isChecked = YES;
        [_checkmarkImgView setImage:[UIImage imageNamed:@"gx"]];
    }else{
        _isChecked = NO;
        [_checkmarkImgView setImage:[UIImage imageNamed:@"wgx"]];
    }
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self cancelLocatePicker];
    if (textField.tag > 3){
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect frame = self.view.frame;
                             frame.origin.y = -150;
                             self.view.frame = frame;
                             
                         }];
    }else{
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect frame = self.view.frame;
                             frame.origin.y = 0;
                             self.view.frame = frame;
                             
                         }];
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _addressDetailTF){
        [_addressDetailTF resignFirstResponder];
        [_phoneNumberTF becomeFirstResponder];
    }
    return YES;
}
#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        
        [[SavaData shareInstance] savaDataBool:YES KeyString:@"registToLogin"];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"registFirst" object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginView" object:self.dataDictionary];
        
    }else if(alertView.tag != 2000){
    
    if (!self.locatePicker)
    {
        [self textFieldResignFirstResponder];
        self.locatePicker = [[[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCity delegate:self] autorelease];
        [self.locatePicker showInView:self.view];
        self.countryLb.text = @"中国";
        
    }else if (self.locatePicker.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict)
    {
        [self textFieldResignFirstResponder];
        self.locatePicker = [[[HZAreaPickerView alloc] initWithStyle:HZAreaPickerWithStateAndCity delegate:self] autorelease];
        [self.locatePicker showInView:self.view];
    }else
    {
        return;
    }
    }
    
}

#pragma mark - HZAreaPicker delegate
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    if (picker.pickerStyle == HZAreaPickerWithStateAndCity)
    {
        if ([[picker.locate.state objectForKey:@"title"] isEqualToString:@"中国"])
        {
            countryID = 86;
            self.foreignCityName.hidden = YES;
            self.foreignCityName.userInteractionEnabled = NO;
            self.areaLb.hidden = NO;
            self.areaBtn.userInteractionEnabled = YES;
            self.cityArrow.hidden = NO;
        }
        else
        {
            self.foreignCityName.hidden = NO;
            self.foreignCityName.userInteractionEnabled = YES;
            self.areaLb.hidden = YES;
            self.areaBtn.userInteractionEnabled = NO;
            self.cityArrow.hidden = YES;
        }
    }
    if (picker.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        
        self.areaValue = [NSString stringWithFormat:@"%@ %@ %@", [picker.locate.state objectForKey:@"title"], [picker.locate.city objectForKey:@"title"], [picker.locate.district objectForKey:@"title"]];
        provinceID = [[picker.locate.state objectForKey:@"area_id"] integerValue];
        cityID = [[picker.locate.city objectForKey:@"area_id"] integerValue];
        districtID = [[picker.locate.district objectForKey:@"area_id"] integerValue];
    }
    else
    {
        if ([[picker.locate.city objectForKey:@"title"] length] == 0) {
            picker.locate.city = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"title", nil];
        }
        self.cityValue = [NSString stringWithFormat:@"%@ %@", [picker.locate.state objectForKey:@"title"], [picker.locate.city objectForKey:@"title"]];
        
    }
}
- (void)piskerDidNoTSelctedChina
{
    [_areaLb setText:@"暂无数据，请填写地址详情"];
    _areaBtn.enabled = NO;
}
- (void)piskerDidSelctedChina
{
    [_areaLb setText:@"省市地区"];
    _areaBtn.enabled = YES;
}
-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self cancelLocatePicker];
}

#pragma mark - request
-(void)requestSuccess:(ASIFormDataRequest *)request
{
    NSData *responseData = [request responseData];
    JSONDecoder *jSONDecoder = [JSONDecoder decoder];
    NSDictionary *resultDictionary = [jSONDecoder objectWithData:responseData];
    NSString *resultStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"success"]];
    if ([resultStr isEqualToString:@"0"]) {
        NSString *errorStr=[NSString stringWithFormat:@"%@",[resultDictionary objectForKey:@"message"]];
        UIAlertView *alter =[[UIAlertView alloc] initWithTitle:nil message:errorStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        [alter release];
        
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"友情提示" message:@"注册成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.delegate = self;
        alert.tag = 1000;
        [alert show];
        [alert release];
    }
}
-(void)requestFail:(ASIFormDataRequest *)request
{
    [MyToast showWithText:@"请求失败，请检查网络" :140];
}

- (IBAction)clickServiceContactBtn:(id)sender {
    ServiceContactViewController *servView = [[ServiceContactViewController alloc]initWithNibName:iPhone5?@"ServiceContactViewController-5":@"ServiceContactViewController" bundle:nil];
    [self.navigationController pushViewController:servView animated:YES];
    [servView release];
    
}
@end
