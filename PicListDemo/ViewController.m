//
//  ViewController.m
//  PicListDemo
//
//  Created by 李沛林（实习） on 2026/1/13.
//

#import "ViewController.h"
#import <Masonry.h>
#import "MyCollectionViewCell.h"
#import <SDWebImage.h>
#import <MJRefresh.h>

@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *imageUrls;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL hasMoreData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化
    self.imageUrls = [NSMutableArray array];
    self.currentPage = 0;
    //self.isLoading = NO; MJRefresh会自动维护加载状态
    self.hasMoreData = YES;
    
    // UICollectionView
    // 创建布局对象
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;// 滚动方向设置为垂直
    layout.minimumInteritemSpacing = 10;// 水平间距
    layout.minimumLineSpacing = 10;// 垂直间距
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);// 内边距
    
    // 创建UICollectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView = collectionView;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"MyCell"];
    [self.view addSubview:self.collectionView];
    
    // MJRefresh
    __weak typeof(self) weakSelf = self;//to do
    // 在顶部下拉的时候，重新加载新的图片
    // 这里要用子类初始化，因为基类是一个抽象类，没有实现文字等方法
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewRefreshData];
    }];
    MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)self.collectionView.mj_header;
    [header setTitle:@"下拉刷新全部图片" forState:MJRefreshStateIdle];//to do
    [header setTitle:@"松开立即刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"正在加载全新图片..." forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor = [UIColor darkGrayColor];
    header.lastUpdatedTimeLabel.hidden = YES;
    
    // 上划时自动调用替换原来的sroll逻辑，上划加载更多控件
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    //MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.collectionView.mj_footer;
    //[footer setTitle:@"上划加载更多" forState:MJRefreshStateIdle];
    //self.collectionView.mj_footer.hidden = YES;
    
    // Masonry添加约束
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    // 第一次需要加载一次，不加会显示一次mjrefresh的占位文案，因为此时数据源元素为0，header自然就在最上方
    [self loadMoreData];
}

#pragma mark - UICollectionViewDataSource
// 返回cell的总数量
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageUrls.count;
}
// 创建/复用cell+给cell赋值
-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    // 使用SDWebImage加载图片
    NSString *imageUrl = self.imageUrls[indexPath.item];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageRetryFailed | SDWebImageRefreshCached];// options:失败自动重试+刷新缓存
    return cell;
}

#pragma  mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Selected item at: %@",indexPath);
}

// 动态调整列数，调用时机是当collectionview首次加载或者它尺寸发生变化时
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat sectionInset = flowLayout.sectionInset.left + flowLayout.sectionInset.right;// 左右内边距和
    CGFloat interitemSpacing = flowLayout.minimumInteritemSpacing;// cell的水平间距
    CGFloat totalSpacing = sectionInset + interitemSpacing;// 总间距
    NSInteger columnCount = 2;// 列数
    CGFloat width = (collectionView.frame.size.width - totalSpacing) / columnCount;// 单元格的宽度
    CGFloat height = width * 3 / 2; // 高宽比3:2
    return CGSizeMake(width,height);
}

#pragma mark - 图片加载方法
// 底部上划
-(void)loadMoreData {
    if (self.isLoading || !self.hasMoreData) {
        return;
    }
    self.currentPage++;
    
    NSLog(@"正在加载第%ld页数据...",(long)self.currentPage);
    
    // 生成新的URL字符串,固定每次添加n个新的，图片参数使用seed
    NSInteger startIndex = self.imageUrls.count;
    for (NSInteger i = 0;i < 10000;i++) {
        NSString *imageUrl = [NSString stringWithFormat:@"https://picsum.photos/seed/%ld/300/200",startIndex + i];
        if (!imageUrl || imageUrl.length == 0) {
            NSLog(@"无效的URL");
        }
        [self.imageUrls addObject:imageUrl];
    }
//    if (self.hasMoreData) {
//        [self.collectionView.mj_footer endRefreshing];
//    }else {
//        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
//    }
    // 刷新collectionView
    [self.collectionView reloadData];
    self.isLoading = NO;
    
    NSLog(@"第%ld页数据加载完成，当前共%ld张图片",(long)self.currentPage,(long)self.imageUrls.count);
    //self.collectionView.mj_footer.hidden = NO;
}

// 顶部下拉刷新
-(void)loadNewRefreshData{
    // 清空旧数据
    [self.imageUrls removeAllObjects];
    // 重置分页状态，页数归零，重置mj_footer
    self.currentPage = 0;
    self.hasMoreData = YES;
    [self.collectionView.mj_footer resetNoMoreData];//to do
    // 生成新的图片URL数组
    NSMutableArray *newRefreshImageUrls = [NSMutableArray array];
    for (NSInteger i = 0;i < 20;i++) {
        NSInteger randomSeed = arc4random() % 10000;
        NSString *imageUrl = [NSString stringWithFormat:@"https://picsum.photos/seed/%ld/300/200",(long)randomSeed];
        [newRefreshImageUrls addObject:imageUrl];
    }
    // 添加到数据源中
    [self.imageUrls addObjectsFromArray:newRefreshImageUrls];
    [self.collectionView reloadData];
    // 下拉刷新完成，收起
    [self.collectionView.mj_header endRefreshing];
}

@end



