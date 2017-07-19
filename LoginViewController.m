//
//  LoginViewController.m
//  FlexiumVendorControl
//
//  Created by flexium on 2016/10/17.
//  Copyright © 2016年 flexium. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"
@interface LoginViewController ()<NSXMLParserDelegate>
//添加属性(数据类型xml解析)
@property (nonatomic, strong) NSXMLParser *parser;
//标记当前标签，以索引找到XML文件内容
@property (nonatomic, copy) NSString *currentElement;

@property (nonatomic,strong)NSString *currentElementName;

@property (nonatomic,assign)BOOL isCheck;

@property (nonatomic,strong)NSString *returnresult;
//存放我解析出来的数据
@property (nonatomic, strong) NSArray *list;
@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=YES;//上方标题栏
   }
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    UILabel *chooselable=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-90, 80, 180, 45)];
    chooselable.text=@"請選擇使用廠區";
    chooselable.font=[UIFont systemFontOfSize:22];
    [chooselable setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:chooselable];
    UIButton *kunshanbtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-90, 205, 180, 45)];
    [kunshanbtn setTitle:@"昆山廠" forState:UIControlStateNormal];
    [kunshanbtn setBackgroundColor:[UIColor lightGrayColor]];
    [kunshanbtn addTarget:self action:@selector(chosekunshan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:kunshanbtn];
    UIButton *gaoxiongbtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-90, 285, 180, 45)];
    [gaoxiongbtn setTitle:@"高雄廠" forState:UIControlStateNormal];
    [gaoxiongbtn addTarget:self action:@selector(chosegaoxiong) forControlEvents:UIControlEventTouchUpInside];
    [gaoxiongbtn setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:gaoxiongbtn];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 选择了昆山厂的方法
-(void)chosekunshan{
    NSLog(@"選擇了崑山廠");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fn = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"kunshan.plist"];
    NSDictionary *dic = @{@"isFirstLaunch":@1};
    [dic writeToFile:fn atomically:YES];
   
    NSString *message=@"1";
   
        [self websever:message]; 
   
    
}
#pragma mark 选择了高雄厂的方法
-(void)chosegaoxiong{
      NSLog(@"選擇了高雄廠");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fn = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"gaoxiong.plist"];
    NSDictionary *dic = @{@"isFirstLaunch":@1};
    [dic writeToFile:fn atomically:YES];
    NSString *message=@"2";
   [self websever:message];
}
#pragma mark 现在进行网络请求
-(void)websever:(NSString *)message{
    NSString *urlStr = @"http://10.2.22.187:81/APPDBWFFConnect.asmx";
    NSURL *url = [NSURL URLWithString:urlStr];
    // 2.创建session对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    // 4.设置请求方式与参数
    request.HTTPMethod = @"POST";
    NSString *str1=@"<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><APPQQ xmlns='http://tempuri.org/'><message>";
    NSString *str2=@"</message></APPQQ></soap:Body></soap:Envelope>";
    NSString *dataStr = [NSString stringWithFormat:@"%@%@%@",str1,message,str2];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    NSString *msgLength=  [NSString stringWithFormat:@"%zd",(int*)dataStr.length];
    [request setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"http://tempuri.org/APPQQ" forHTTPHeaderField:@"Action"];
    
    
    // 5.进行链接请求数据
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"请求数据出错!----%@",error.description);
              dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                                 message:@""
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@"确定",nil];
                  [alert show];});
            UIStoryboard *sb =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ViewController *mevc=[sb instantiateInitialViewController];
            [self presentViewController:mevc animated:YES completion:nil];
        } else {
            self.parser=[[NSXMLParser alloc]initWithData:data];
            NSLog(@"%@",self.parser);
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
//遍历查找xml中文件的元素
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    _currentElementName = elementName;
    if ([_currentElementName isEqualToString:@"APPQQResult"]) {
        _isCheck = true;
        _returnresult = @"";
    }
}

//把第一个代理中我们要找的信息存储在currentstring中并把要找的信息空格和换行符号去除
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([_currentElementName isEqualToString:@"APPQQResult"]) {
        _isCheck = true;
        _returnresult =[_returnresult stringByAppendingString:string] ;
        self.list= [self.returnresult componentsSeparatedByString:@";"];
    }
}

//把上部的信息存储到数据中
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if (_list.count>1) {
        [[NSUserDefaults standardUserDefaults] setValue:_list forKey: @"area"];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *sb =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ViewController *mevc=[sb instantiateInitialViewController];
            [self presentViewController:mevc animated:YES completion:nil];
        });
    }
}

@end
