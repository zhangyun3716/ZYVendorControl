//  AppDelegate.m
//  FlexiumVendorControl
//  Created by flexium on 2016/10/12.
//  Copyright © 2016年 flexium. All rights reserved.

#import "AppDelegate.h"
#import "ViewController.h"
#import "LoginViewController.h" 
@interface AppDelegate ()<NSXMLParserDelegate>
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

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:[UIColor grayColor]];
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fn=[[paths objectAtIndex:0]stringByAppendingPathComponent:@"kunshan.plist"];
    NSString *fg=[[paths objectAtIndex:0]stringByAppendingPathComponent:@"gaoxiong.plist"];
    NSFileManager *fm=[NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:fn]||[fm fileExistsAtPath:fg]) {
        
       
        NSString *message =@"";
        if ([fm fileExistsAtPath:fn]) {
             message=@"1";
        }else{
             message=@"2";
        }
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
                     [alert show];
                 });
                
            } else {
                self.parser=[[NSXMLParser alloc]initWithData:data];
             //  NSLog(@"%@",self.parser);
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
        UIStoryboard *sb =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *mevc=[sb instantiateInitialViewController];
        self.window.rootViewController =[[UINavigationController alloc]initWithRootViewController:mevc];
    }
    else{
       self.window.rootViewController =[[UINavigationController alloc]initWithRootViewController:[[LoginViewController alloc]init]];
 
    };
    
    [self.window makeKeyAndVisible];
    return YES;
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
    //NSLog(@"%@",_list);
    if (_list.count>1) {
   [[NSUserDefaults standardUserDefaults] setValue:_list forKey: @"area"];
    }
   
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
