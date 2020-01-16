//
//  SCLServiceInfoView.m
//  SconSample
//
//  Created by gezhixin on 2018/9/14.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "SCLServiceInfoView.h"
#import "Scon.h"
#import "SCLSocketConnection.h"
#import "SCLogPlugin.h"
#import "SCServerInfo.h"

#define BaseHeight (30.f)
#define ExpandHeight (100.0f)
#define BaseWidth  (120.0f)
#define ExpandWidth (180.0f)

__weak SCLServiceInfoView * g_weakServiceInfoView;

@interface SCLServiceInfoView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *headerContentView;
@property (nonatomic, strong) UIView *activeStateView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *arrowIcon;

@property (nonatomic, strong) SCLSocketConnection *connection;
@property (nonatomic, strong) SCLogPlugin *logPlugin;

@property (nonatomic, assign) BOOL isExpand;

@property (nonatomic, strong) SCServerInfo *selectedServiceInfo;

@end

@implementation SCLServiceInfoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addNotifications];
        [self _loadView];
        [self _initSconService];
        [self updateView];
    }
    return self;
}

- (void)dealloc {
    [self.connection close];
    [[Scon sharedInstance] setConnection:nil];
    [[Scon sharedInstance] removePlugin:self.logPlugin];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteServverListChanged:) name:kSCLServieListCHanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionActiveStateChanged:) name:kSCConnectionActiveStateCHanged object:nil];
}

- (void)_initSconService {
    self.connection = [[SCLSocketConnection alloc] init];
    self.logPlugin = [[SCLogPlugin alloc] init];
    [[Scon sharedInstance] setConnection:self.connection];
    [[Scon sharedInstance] addPlugin:self.logPlugin];
}

- (void)_loadView {
    self.frame = CGRectMake(30, 100, BaseWidth, self.isExpand ? ExpandHeight : BaseHeight);
    self.backgroundColor = [UIColor colorWithRed:(CGFloat)(0xee) / (CGFloat)(0xff) green:(CGFloat)(0xee) / (CGFloat)(0xff) blue:(CGFloat)(0xee) / (CGFloat)(0xff) alpha:0.75];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = BaseHeight / 2;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor redColor].CGColor;
    
    self.headerContentView = [[UIView alloc] init];
    [self addSubview:_headerContentView];
    
    _activeStateView = [[UIView alloc] init];
    _activeStateView.layer.masksToBounds = YES;
    [_headerContentView addSubview:_activeStateView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont systemFontOfSize:12];
    [_headerContentView addSubview:_titleLabel];
    
    _arrowIcon = [[UIImageView alloc] init];
    
    [_headerContentView addSubview:_arrowIcon];
    
    _tableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = 26;
    [self addSubview:_tableView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}

#pragma mark - actions
- (void)tap:(UITapGestureRecognizer *)tap {
    self.isExpand = !self.isExpand;
    [self updateView];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint pt = [pan translationInView:self];
    CGFloat x = MAX(self.frame.size.width / 2 + 15, pan.view.center.x +pt.x);
    x = MIN(x, [UIScreen mainScreen].bounds.size.width - self.frame.size.width / 2 - 15);
    CGFloat y = MAX(pan.view.center.y + pt.y, self.frame.size.height / 2 + 30);
    y = MIN(y, [UIScreen mainScreen].bounds.size.height - self.frame.size.height - 30);
    pan.view.center = CGPointMake(x, y);
    
    [pan setTranslation:CGPointMake(0, 0) inView:self];
}

- (void)onConnectionActiveStateChanged:(NSNotification *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateView];
    });
}
                                        
- (void)onRemoteServverListChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.selectedServiceInfo) {
            self.selectedServiceInfo = self.connection.remoteServiceList.firstObject;
        } else if(self.connection.remoteServiceList.count == 0) {
            self.selectedServiceInfo = nil;
        }
        [self updateView];
    });
    
}

#pragma mark - UI
- (void)_layoutView {
    
    CGFloat viewWidth = self.isExpand ? ExpandWidth : BaseWidth;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, viewWidth, self.isExpand ? ExpandHeight : BaseHeight);
    
    self.headerContentView.frame = CGRectMake(0, 0, viewWidth, BaseHeight);
    
    self.activeStateView.frame = CGRectMake(10, 10, 10, 10);
    self.activeStateView.layer.cornerRadius = 5;
    
    self.titleLabel.frame = CGRectMake(self.activeStateView.frame.origin.x + self.activeStateView.frame.size.width + 4, 0, viewWidth - 44, BaseHeight);
    
    self.arrowIcon.frame = CGRectMake(viewWidth - 26, 5, 21, 21);
    
    self.tableView.frame = CGRectMake(0, BaseHeight + 4, viewWidth, self.frame.size.height - BaseHeight - 4);
}

- (void)updateView {
    [self _layoutView];
    
    _titleLabel.text = self.selectedServiceInfo ? self.selectedServiceInfo.name : @"no server selected";
    _arrowIcon.image = [self arrowImage];
    _activeStateView.backgroundColor = self.connection.active ? [UIColor redColor] : [UIColor grayColor];
    [self.tableView reloadData];
}

- (UIImage *)arrowImage {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Bonjour" ofType:@"bundle"];
    NSString *imageName = self.isExpand ? @"fold" : @"unfold";
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", bundlePath, imageName]];
}

#pragma mark - setter
- (void)setSelectedServiceInfo:(SCServerInfo *)selectedServiceInfo {
    if (_selectedServiceInfo == selectedServiceInfo) {
        if (!self.connection.isConnected) {
            [self.connection connectService:_selectedServiceInfo];
        }
        return;
    }
    
    _selectedServiceInfo = selectedServiceInfo;
    if (_selectedServiceInfo) {
        [self.connection connectService:_selectedServiceInfo];
    }
    
    [self updateView];
}

#pragma mark - Public Methold
+ (instancetype)show {
    
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    
    if (!keyWindow) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SCLServiceInfoView show];
        });
        return nil;
    }
    
    if (g_weakServiceInfoView) {
        return g_weakServiceInfoView;
    }
    SCLServiceInfoView * view = [[SCLServiceInfoView alloc] init];
    [keyWindow addSubview:view];
    g_weakServiceInfoView = view;
    return g_weakServiceInfoView;
}

+ (void)remove {
    if (g_weakServiceInfoView) {
        [g_weakServiceInfoView removeFromSuperview];
        g_weakServiceInfoView = nil;
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.connection.remoteServiceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"remoteServerInfoCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"remoteServerInfoCell"];
        cell.selectedBackgroundView = [UIView new];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.backgroundColor = [UIColor clearColor];
    }
    SCServerInfo * info = self.connection.remoteServiceList[indexPath.row];
    cell.textLabel.text = info.name;
    cell.textLabel.textColor = self.selectedServiceInfo == info ? [UIColor redColor] : [UIColor blackColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SCServerInfo * info = self.connection.remoteServiceList[indexPath.row];
    self.selectedServiceInfo = info;
    self.isExpand = NO;
    [self updateView];
}

@end
