//  ViewController.m
//  FlexiumManufacturerinorout2
//  Created by flexium on 2016/10/6.
//  Copyright © 2016年 flexium. All rights reserved.

#import "ViewController.h"
#import "ZYScannerView.h"
@interface ViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,NSXMLParserDelegate>

- (IBAction)SelectArea:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *quyuming;
- (IBAction)InOrOut:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *Jingchubiaoji;

- (IBAction)BeginScan:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIButton *areasender;

//地区数组
@property (strong,nonatomic) NSMutableArray *AreaArray;
@property (strong,nonatomic) NSMutableArray *PlaceArray;
//pickerView的定义显示
@property (nonatomic,strong) UIView * secondview;
@property (nonatomic, strong) UIPickerView *pickerView;
@property(nonatomic,copy)NSString *arestr;
@property (strong, nonatomic) IBOutlet UILabel *CertificateNum;
@property (strong, nonatomic) IBOutlet UILabel *Carnumb;
@property (strong, nonatomic) IBOutlet UILabel *Name;

@property (strong, nonatomic) IBOutlet UILabel *Place;
@property (strong, nonatomic) IBOutlet UILabel *Contents;

@property (strong, nonatomic) IBOutlet UILabel *Vendor;
@property (strong, nonatomic) IBOutlet UILabel *Date;

@property (strong, nonatomic) IBOutlet UILabel *DateStar;
@property (strong, nonatomic) IBOutlet UILabel *Date_end;
//进出厂标记
@property (assign ,nonatomic) int A;

//标记当前标签，以索引找到XML文件内容
@property (nonatomic, copy) NSString *currentElement;

@property (nonatomic,strong)NSString *currentElementName;

@property (nonatomic,assign)BOOL isCheck;

@property (nonatomic,strong)NSString *returnresult;

//添加属性(数据类型xml解析)
@property (nonatomic, strong) NSXMLParser *parser;

//存放我解析出来的数据
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) NSArray *arraylist;
//进入大区域名
@property (nonatomic, strong) NSString *placetext;
@property (nonatomic,strong) NSString *Facetory;
@property (nonatomic,strong)NSString *passtext;
@property (nonatomic,strong)NSArray *passarray;
@property (nonatomic,strong)NSMutableArray *placearry;//区域名
//定时操作
@property (nonatomic,strong)NSTimer *time;
@property (strong, nonatomic) IBOutlet UIButton *selectarea;
@property (strong, nonatomic) IBOutlet UILabel *gongju;


@end

@implementation ViewController


-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden=YES;//下方导航栏
    self.tabBarItem.accessibilityElementsHidden=YES;
    self.navigationController.navigationBarHidden=YES;//上方标题栏
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self huoqushuju];
    if (self.AreaArray.count>0&&self.PlaceArray.count>0) {
        self.quyuming.text=_AreaArray[0];
        self.placetext=_PlaceArray[0];
    }
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAction:)];
    recognizer.minimumPressDuration = 5; //设置最小长按时间；默认为0.5秒
    recognizer.numberOfTouchesRequired = 1;
    [self.selectarea addGestureRecognizer:recognizer];
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fn=[[paths objectAtIndex:0]stringByAppendingPathComponent:@"kunshan.plist"];
    NSFileManager *fm=[NSFileManager defaultManager];
        if ([fm fileExistsAtPath:fn]) {
            _Facetory=@"1";
        }else{
            _Facetory=@"2";
        }

 //以下設置為默認廠商進入
    self.A=1;
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:@"廠商進廠"];
    [AttributedStr addAttribute:NSForegroundColorAttributeName
                          value:[UIColor  redColor]
                          range:NSMakeRange(2, 1)];
    [AttributedStr addAttribute:NSFontAttributeName
     
                          value:[UIFont systemFontOfSize:20.0]
     
                          range:NSMakeRange(2, 1)];
    self.Jingchubiaoji.attributedText = AttributedStr;
    [self.areasender setBackgroundImage:[UIImage imageNamed:@"入库.png"] forState:UIControlStateNormal];

//查詢是否已經選擇過若沒有就繼續幹活
      _placearry=[[NSMutableArray alloc]init];
    _placearry=[[NSUserDefaults standardUserDefaults]valueForKey:@"place"];
    
      NSLog(@"%@",_placearry);
    if (_placearry.count>0) {
 //直接显示就行了
        NSLog(@"%@",_placearry);
        self.quyuming.text=_placearry[0];
        self.placetext=_placearry[1];
        }

}
#pragma mark 获取地区和地点的数据
-(void)huoqushuju{
    _arraylist=[[NSArray alloc]init];
    _arraylist = [[NSUserDefaults standardUserDefaults] valueForKey:@"area"];
    if (_arraylist.count>2) {
        _AreaArray =[[NSMutableArray alloc]init];
        _PlaceArray=[[NSMutableArray alloc]init];
        for (int i=0; i<_arraylist.count-1; i++) {
            int a=i%2;
            if (a==0) {
                [_AreaArray addObject:_arraylist[i]];
            }else{
                [_PlaceArray addObject:_arraylist[i]];
            }
    }
//        self.quyuming.text=_AreaArray[0];
//        self.placetext=_PlaceArray[0];
  }
   // NSLog(@"%@,%@",_AreaArray,_PlaceArray);
}
//#pragma mark 隐藏状态栏
//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark 选择区域开关
- (IBAction)SelectArea:(UIButton *)sender {
    _placearry=[[NSUserDefaults standardUserDefaults]valueForKey:@"place"];
    if (_placearry.count>0) {
        //直接显示就行了
        NSLog(@"提醒");
    }else{
        [self areajiemian];
    }
    
}
#pragma mark 长按手势
- (void) longTapAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long pressTap state :begin");
        [self areajiemian];
    }else {
        NSLog(@"long pressTap state :end");
    }
    
}
#pragma mark 选择区域界面
-(void)areajiemian{
    self.secondview =[[UIView alloc]initWithFrame:self.view.frame];
    self.pickerView =[[UIPickerView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 500)];
    self.pickerView.dataSource=self;
    self.pickerView.delegate=self;
    [self.pickerView selectRow:self.AreaArray.count/2 inComponent:0 animated:YES];
    self.quyuming.text=self.AreaArray[0];
    [self.secondview addSubview:self.pickerView];
    [self.view addSubview:self.secondview];
    self.secondview.backgroundColor=[UIColor whiteColor];
    UIButton *btn1=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2-20, self.view.bounds.size.height-80, 140, 50)];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"normal1.png"] forState:UIControlStateNormal];
    [btn1 setTitle:@"確認" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.secondview addSubview:btn1];
    [btn1 addTarget:self action:@selector(SureChoose) forControlEvents:UIControlEventTouchUpInside];

}

#pragma mark 确认选择区域
-(void)SureChoose{
    self.secondview.hidden=YES;
    [self.secondview removeFromSuperview];
}

#pragma mark  看看有多少行
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

#pragma mark 控件部分有多少行数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.AreaArray.count;
}

#pragma mark 返回高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.0f;
}

#pragma mark 返回宽度
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 200;
}
#pragma mark 显示数字
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString  *str=self.AreaArray[row];
    return str;
}
#pragma mark 在行上面返回视图
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *mycom1 = view ? (UILabel *) view : [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 30.0f)];
    [mycom1 setTextAlignment:NSTextAlignmentCenter];
    mycom1.textColor=[UIColor blackColor];
    NSString *imgstr1 = self.AreaArray[row];
    mycom1.text = imgstr1;
    [mycom1 setFont:[UIFont systemFontOfSize: 18]];
    mycom1.backgroundColor = [UIColor whiteColor];
    return mycom1;
}
#pragma mark 地点地址显示
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [_quyuming setText:self.AreaArray[row]];
    self.placetext=self.PlaceArray[row];
    _placearry =[[NSMutableArray alloc ]init];
    [_placearry addObject:_quyuming.text];
    [self.placearry addObject:self.placetext];
      NSLog(@"%@",_placearry);
    [[NSUserDefaults standardUserDefaults] setValue:self.placearry forKey: @"place"];
    NSLog(@"%@",_placetext);
}
#pragma mark 进出库选择
- (IBAction)InOrOut:(UIButton *)sender {
    sender.selected=!sender.selected;
    if (sender.selected==1) {
        [sender setBackgroundImage:[UIImage imageNamed:@"出库.png"] forState:UIControlStateNormal];
        [self.Jingchubiaoji setText:@"廠商出廠"];
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:@"廠商出廠"];
            [AttributedStr addAttribute:NSForegroundColorAttributeName
                                  value:[UIColor  redColor]
                                  range:NSMakeRange(2, 1)];
        [AttributedStr addAttribute:NSFontAttributeName
         
                              value:[UIFont systemFontOfSize:20.0]
         
                              range:NSMakeRange(2, 1)];
            self.Jingchubiaoji.attributedText = AttributedStr;

        self.A=2;
        NSLog(@"出厂");
    }
    else{
        [sender setBackgroundImage:[UIImage imageNamed:@"入库.png"] forState:UIControlStateNormal];
        [self.Jingchubiaoji setText:@"廠商進廠"];
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:@"廠商進廠"];
        [AttributedStr addAttribute:NSForegroundColorAttributeName
                              value:[UIColor  redColor]
                              range:NSMakeRange(2, 1)];
        [AttributedStr addAttribute:NSFontAttributeName
         
                              value:[UIFont systemFontOfSize:20.0]
         
                              range:NSMakeRange(2, 1)];
        self.Jingchubiaoji.attributedText = AttributedStr;
        self.A=1;
        NSLog(@"进厂");
    }
    
}
#pragma mark 开始扫描
- (IBAction)BeginScan:(UIButton *)sender {
        self.list=nil;
         _passtext=@"";
    [[ZYScannerView sharedScannerView] showOnView:self.view block:^(NSString *str) {
        [self.time invalidate];
        self.time=nil;
        [self action];
        _time = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(action) userInfo:nil repeats:NO];
        _CertificateNum.text=str;
        // NSLog(@"%@",str);
        //这里是去webserver端抓取数据，并存储数据到服务端，自动判断改用户是否具备进入权限。
        NSString * type=@"";
        if (_A==1) {
            type=@"in";
        }
        else {
            type=@"out";
        }
        NSString *message= [type stringByAppendingFormat:@";%@;%@;%@;%@",str,_quyuming.text,_placetext,_Facetory];
        NSLog(@"%@",message);
        NSLog(@"--------%@",message);
        [self websever:message];
        
    }];
}
#pragma mark 清空数据
-(void)action{
    //self.list=nil;
    _CertificateNum.text=nil;
    _Name.text=nil;
    _Place.text=nil;
    _Contents.text=nil;
    _Vendor.text=nil;
    _Date.text=nil;
    _DateStar.text=nil;
    _Date_end.text=nil;
     self.gongju.text=nil;
    [self.time invalidate];
    self.time=nil;
   
}
#pragma mark 现在进行网络请求
-(void)websever:(NSString *)message{
    NSLog(@"message:%@",message);
    NSString *urlStr = @"http://10.2.22.187:81/APPDBWFFConnect.asmx";
    NSURL *url = [NSURL URLWithString:urlStr];
    // 2.创建session对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // 4.设置请求方式与参数
    request.HTTPMethod = @"POST";
    NSString *str1=@"<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><APPMethod xmlns='http://tempuri.org/'><message>";
    NSString *str2=@"</message></APPMethod></soap:Body></soap:Envelope>";
    NSString *dataStr = [NSString stringWithFormat:@"%@%@%@",str1,message,str2];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    NSString *msgLength=  [NSString stringWithFormat:@"%zd",(int*)dataStr.length];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"http://tempuri.org/APPMethod" forHTTPHeaderField:@"Action"];
    
    
    // 5.进行链接请求数据
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"请求数据出错!----%@",error.description);
            [self intenererror];
        } else {
            self.parser=[[NSXMLParser alloc]initWithData:data];
            NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
            NSLog(@"%@",result);
            //添加代理
            self.parser.delegate=self;
            //self.list = [NSMutableArray arrayWithCapacity:9];
            //这一步不能少！
            self.parser.shouldResolveExternalEntities=true;
            //开始解析
            [self.parser parse];
            
        }
    }];
    // 6.开启请求数据
    [dataTask resume];
}

#pragma mark 遍历查找xml中文件的元素
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    _currentElementName = elementName;
    if ([_currentElementName isEqualToString:@"APPMethodResult"]) {
        _isCheck = true;
        _returnresult = @"";
    }
}

#pragma mark 把第一个代理中我们要找的信息存储在currentstring中并把要找的信息空格和换行符号去除
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([_currentElementName isEqualToString:@"APPMethodResult"]) {
        _isCheck = true;
        _returnresult =[_returnresult stringByAppendingString:string] ;
        self.list= [self.returnresult componentsSeparatedByString:@";"];
    }
}

#pragma mark 把上部的信息存储到数据中
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
  
}
#pragma mark 解析结束数据
- (void)parserDidEndDocument:(NSXMLParser *)parser{
   NSLog(@"%@",_list);
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"%zd",self.list.count);
        if ([self.list[0] isEqualToString:@"OK" ]) {
            NSDate *  senddate=[NSDate date];
            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"YYYY/MM/dd"];
            NSString *  locationString=[dateformatter stringFromDate:senddate];
            //  NSLog(@"%@",locationString);
            //本位置判断区域是不是符合若不符合则不允许进入
            NSLog(@"%@,%@",_list[5],_placetext);
            NSArray *placetextarray=[_list[5] componentsSeparatedByString:@"-"];
            for (int i=0; i<placetextarray.count; i++) {
                if ([_placetext isEqualToString:placetextarray[i]]) {
                    _passtext=@"通用";
                }
            }
            NSLog(@"111212122%@%@121212121",_placetext,_passtext);
            //这个——palcetext是上传的区域名。passtext是多个就进行对比
            if ([_placetext isEqualToString:_list[5]]||([_placetext isEqualToString:@"通用"]||[_passtext isEqualToString:@"通用"])) {
                NSLog(@"%@----%@",_placetext,_passtext);
                _Name.text=_list[8];
                _Name.textColor=[UIColor blackColor];
                NSString *text=@"";
                // NSLog(@"%@",placetextarray);
                _passarray=placetextarray;
                for (int i=0; i<placetextarray.count; i++) {
                    if (i<placetextarray.count-1) {
                        text=[text stringByAppendingFormat:@"%@\n",placetextarray[i]];
                    }else{
                        text=[text stringByAppendingFormat:@"%@",placetextarray[i]];
                    }
                    
                }
                if (placetextarray.count>1) {
                    _Place.text=text;
                    _Place.textAlignment=NSTextAlignmentLeft;
                    _Place.numberOfLines=0;
                    _Place.font=[UIFont systemFontOfSize:15];
                }else{
                    _Place.text=_list[5];//施工地点
                }
                // NSLog(@"%@",_Place.text);
                _Contents.text=_list[6];
                _Vendor.text=_list[7];
                _Date.text=locationString;
                NSString *startime=_list[2];
                startime=[startime substringToIndex:10];
                NSString*endtime=_list[3];
                endtime=[endtime substringToIndex:10];
                _DateStar.text=startime;
                _Date_end.text=endtime;
                if (_list.count==10) {
                    _gongju.text=_list[9];
                }else{
                     _gongju.text=@"未登记需要携带工具（或在另一个进出单上）";
                }
                
            }
            else{
                if (_list.count==10) {
                    _gongju.text=_list[9];
                }else{
                    _gongju.text=@"未登记需要携带工具（或在另一个进出单上）";
                }
                _Name.text=_list[8];
                _Name.textColor=[UIColor blackColor];
                _Place.text=@"無進入權限";
                _Place.textColor=[UIColor redColor];
                _Contents.text=_list[6];
                _Vendor.text=_list[7];
                _Date.text=locationString;
                NSString *startime=_list[2];
                startime=[startime substringToIndex:10];
                NSString*endtime=_list[3];
                endtime=[endtime substringToIndex:10];
                _DateStar.text=startime;
                _Date_end.text=endtime;
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"與申請區域不符！" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                UIView *subView1 = alertController.view.subviews[0];
                UIView *subView2 = subView1.subviews[0];
                UIView *subView3 = subView2.subviews[0];
                UIView *subView4 = subView3.subviews[0];
                UIView *subView5 = subView4.subviews[0];
                NSLog(@"%@",subView5.subviews);
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
                //修改title
                NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"與申請區域不符！"];
                [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 8)];
                [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 8)];
                [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
                [cancelAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];
            }
            
        }else{
            _Name.text=self.list[1];
            _Name.textColor=[UIColor redColor];
            _Place.text=nil;
            _Contents.text=nil;
            _Vendor.text=nil;
            _Date.text=nil;
            _DateStar.text=nil;
            _Date_end.text=nil;
            _gongju.text=nil;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"該證件無效！" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
            //修改title
            NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"該證件無效！"];
            [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 6)];
            [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 6)];
            [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
            [cancelAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];        }
    });
    
}
#pragma mark 網絡錯誤提示界面
-(void)intenererror{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"網絡錯誤" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    //修改title
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:@"網絡錯誤"];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, 4)];
    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
    [cancelAction setValue:[UIColor blueColor] forKey:@"titleTextColor"];
    [self action];
}

@end

