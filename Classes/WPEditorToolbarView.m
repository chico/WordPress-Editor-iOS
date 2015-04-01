#import "WPEditorToolbarView.h"
#import "WPDeviceIdentification.h"
#import "WPEditorToolbarButton.h"
#import "ZSSBarButtonItem.h"
#import "FontAwesomeKit.h"

static int kDefaultToolbarItemPadding = 20;
static int kDefaultToolbarLeftPadding = 20;

static int kNegativeToolbarItemPadding = 12;
static int kNegativeSixToolbarItemPadding = 6;
static int kNegativeSixPlusToolbarItemPadding = 2;
static int kNegativeLeftToolbarLeftPadding = 3;
//static int kNegativeRightToolbarPadding = 20;
//static int kNegativeSixPlusRightToolbarPadding = 24;

static const CGFloat WPEditorToolbarHeight = 40;
static const CGFloat WPEditorToolbarButtonHeight = 40;
static const CGFloat WPEditorToolbarButtonWidth = 40;
//static const CGFloat WPEditorToolbarDividerLineHeight = 28;
//static const CGFloat WPEditorToolbarDividerLineWidth = 0.6f;

@interface WPEditorToolbarView ()

#pragma mark - Properties: Toolbar
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *topBorderView;
@property (nonatomic, weak) UIToolbar *leftToolbar;
@property (nonatomic, weak) UIToolbar *rightToolbar;
@property (nonatomic, weak) UIView *rightToolbarHolder;
@property (nonatomic, weak) UIView *rightToolbarDivider;
@property (nonatomic, weak) UIScrollView *toolbarScroll;

#pragma mark - Properties: Toolbar items
@property (nonatomic, strong, readwrite) UIBarButtonItem* htmlBarButtonItem;

/**
 *  Toolbar items to include
 */
@property (nonatomic, assign, readwrite) ZSSRichTextEditorToolbar enabledToolbarItems;

@end

@implementation WPEditorToolbarView

/**
 *  @brief      Initializer for the view with a certain frame.
 *
 *  @param      frame       The frame for the view.
 *
 *  @return     The initialized object.
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _enabledToolbarItems = [self defaultToolbarItems];
        [self buildToolbar];
    }
    
    return self;
}

#pragma mark - Toolbar building

- (void)buildToolbar
{
    [self buildMainToolbarHolder];
    [self buildToolbarScroll];
    [self buildLeftToolbar];
    
    if (!IS_IPAD) {
        [self.contentView addSubview:[self rightToolbarHolder]];
    }
}

- (void)reloadItems
{
    if (IS_IPAD) {
        [self reloadiPadItems];
    } else {
        [self reloadiPhoneItems];
    }
}

- (void)reloadiPhoneItems
{
    NSMutableArray *items = [self.items mutableCopy];
    CGFloat toolbarItemsSeparation = 0.0f;
    
    if ([WPDeviceIdentification isiPhoneSixPlus]) {
        toolbarItemsSeparation = kNegativeSixPlusToolbarItemPadding;
    } else if ([WPDeviceIdentification isiPhoneSix]) {
        toolbarItemsSeparation = kNegativeSixToolbarItemPadding;
    } else {
        toolbarItemsSeparation = kNegativeToolbarItemPadding;
    }
    
    CGFloat toolbarWidth = 0.0f;
    NSUInteger numberOfItems = items.count;
    if (numberOfItems > 0) {
        CGFloat finalPaddingBetweenItems = kDefaultToolbarItemPadding - toolbarItemsSeparation;
        
        toolbarWidth += (numberOfItems * WPEditorToolbarButtonWidth);
        toolbarWidth += (numberOfItems * finalPaddingBetweenItems);
    }
    
    UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil
                                                                                       action:nil];
    negativeSeparator.width = -toolbarItemsSeparation;
    
    // This code adds a negative separator between all the toolbar buttons
    for (NSInteger i = [items count]; i >= 0; i--) {
        [items insertObject:negativeSeparator atIndex:i];
    }
    
    UIBarButtonItem *negativeSeparatorForToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                                 target:nil
                                                                                                 action:nil];
    CGFloat finalToolbarLeftPadding = kDefaultToolbarLeftPadding - kNegativeLeftToolbarLeftPadding;
    
    negativeSeparatorForToolbar.width = -kNegativeLeftToolbarLeftPadding;
    toolbarWidth += finalToolbarLeftPadding;
    self.leftToolbar.items = items;
    self.leftToolbar.frame = CGRectMake(0, 0, toolbarWidth, WPEditorToolbarHeight);
    self.toolbarScroll.contentSize = CGSizeMake(CGRectGetWidth(self.leftToolbar.frame),
                                                WPEditorToolbarHeight);
}

- (void)reloadiPadItems
{
    NSMutableArray *items = [self.items mutableCopy];
    CGFloat toolbarWidth = CGRectGetWidth(self.toolbarScroll.frame);
    UIBarButtonItem *flexSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];
    UIBarButtonItem *buttonSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                  target:nil
                                                                                  action:nil];
    buttonSpacer.width = WPEditorToolbarButtonWidth;
    [items insertObject:buttonSpacer atIndex:1];
    [items insertObject:buttonSpacer atIndex:5];
    [items insertObject:buttonSpacer atIndex:7];
    [items insertObject:buttonSpacer atIndex:11];
    [items insertObject:flexSpacer atIndex:0];
    [items insertObject:flexSpacer atIndex:items.count];
    self.leftToolbar.items = items;
    self.leftToolbar.frame = CGRectMake(0, 0, toolbarWidth, WPEditorToolbarHeight);
    self.toolbarScroll.contentSize = CGSizeMake(CGRectGetWidth(self.leftToolbar.frame),
                                                WPEditorToolbarHeight);
}

#pragma mark - Toolbar building helpers

- (void)buildLeftToolbar
{
    NSAssert(_leftToolbar == nil, @"This is supposed to be called only once.");
    
    UIToolbar* leftToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    leftToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    leftToolbar.barTintColor = self.backgroundColor;
    leftToolbar.translucent = NO;
    
    // We had some issues with the left toolbar not resizing properly - and we didn't realize
    // immediately.  Clipping to bounds is a good way to realize sooner and not later.
    //
    leftToolbar.clipsToBounds = YES;
    
    [self.toolbarScroll addSubview:leftToolbar];
    self.leftToolbar = leftToolbar;
}

- (void)buildMainToolbarHolder
{    
    CGRect subviewFrame = self.frame;
    subviewFrame.origin = CGPointZero;
    
    UIView* mainToolbarHolderContent = [[UIView alloc] initWithFrame:subviewFrame];
    mainToolbarHolderContent.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    subviewFrame.size.height = 1.0f;
    
  //  UIView* mainToolbarHolderTopBorder = [[UIView alloc] initWithFrame:subviewFrame];
  //  mainToolbarHolderTopBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //mainToolbarHolderTopBorder.backgroundColor = self.borderColor;
    
    [self addSubview:mainToolbarHolderContent];
   // [self addSubview:mainToolbarHolderTopBorder];
    
    self.contentView = mainToolbarHolderContent;
    //self.topBorderView = mainToolbarHolderTopBorder;
}

- (void)buildToolbarScroll
{
    NSAssert(_toolbarScroll == nil, @"This is supposed to be called only once.");
    
    CGFloat scrollviewHeight = CGRectGetWidth(self.frame);
    
    if (!IS_IPAD) {
        scrollviewHeight -= WPEditorToolbarButtonWidth;
    }
    
    CGRect toolbarScrollFrame = CGRectMake(0,
                                           0,
                                           scrollviewHeight,
                                           WPEditorToolbarHeight);
    
    UIScrollView* toolbarScroll = [[UIScrollView alloc] initWithFrame:toolbarScrollFrame];
    toolbarScroll.showsHorizontalScrollIndicator = NO;
    //if (IS_IPAD) {
        toolbarScroll.scrollEnabled = NO;
    //}
    toolbarScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.contentView addSubview:toolbarScroll];
    self.toolbarScroll = toolbarScroll;
}


#pragma mark - Toolbar size

+ (CGFloat)height
{
    return WPEditorToolbarHeight;
}

#pragma mark - Toolbar buttons

- (ZSSBarButtonItem*)barButtonItemWithTag:(WPEditorViewControllerElementTag)tag
                             htmlProperty:(NSString*)htmlProperty
                                imageName:(NSString*)imageName
                                   target:(id)target
                                 selector:(SEL)selector
                       accessibilityLabel:(NSString*)accessibilityLabel
{
    ZSSBarButtonItem *barButtonItem = [[ZSSBarButtonItem alloc] initWithImage:nil
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:nil
                                                                       action:nil];
    barButtonItem.tag = tag;
    barButtonItem.htmlProperty = htmlProperty;
    barButtonItem.accessibilityLabel = accessibilityLabel;
    
    UIImage* buttonImage = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    WPEditorToolbarButton* customButton = [[WPEditorToolbarButton alloc] initWithFrame:CGRectMake(0,
                                                                                                  0,
                                                                                                  WPEditorToolbarButtonWidth,
                                                                                                  WPEditorToolbarButtonHeight)];
    [customButton setImage:buttonImage forState:UIControlStateNormal];
    customButton.normalTintColor = [UIColor colorWithRed:230.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1.0]; //self.itemTintColor;
    customButton.selectedTintColor = [UIColor colorWithRed:230.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1.0];
    [customButton addTarget:target
                     action:selector
           forControlEvents:UIControlEventTouchUpInside];
    barButtonItem.customView = customButton;
    
    return barButtonItem;
}

#pragma mark - Toolbar items

- (BOOL)canShowToolbarOption:(ZSSRichTextEditorToolbar)toolbarOption
{
    return (self.enabledToolbarItems & toolbarOption);
            //|| self.enabledToolbarItems & ZSSRichTextEditorToolbarAll);
}

- (ZSSRichTextEditorToolbar)defaultToolbarItems
{
    ZSSRichTextEditorToolbar defaultToolbarItems = (ZSSRichTextEditorToolbarBold
                                                    | ZSSRichTextEditorToolbarItalic
                                                    | ZSSRichTextEditorToolbarUnorderedList
                                                    | ZSSRichTextEditorToolbarOrderedList
                                                    | ZSSRichTextEditorToolbarInsertImage
                                                    | ZSSRichTextEditorToolbarInsertLink
                                                    
                                                    );
    
    // iPad gets the HTML source button too
    if (IS_IPAD) {
        defaultToolbarItems = (defaultToolbarItems
                               | ZSSRichTextEditorToolbarStrikeThrough
                               | ZSSRichTextEditorToolbarViewSource);
    }
    
    return defaultToolbarItems;
}

- (void)enableToolbarItems:(BOOL)enable
    shouldShowSourceButton:(BOOL)showSource
{
    NSArray *items = self.leftToolbar.items;
    
    for (ZSSBarButtonItem *item in items) {
        if (item.tag == kWPEditorViewControllerElementShowSourceBarButton) {
            item.enabled = showSource;
        } else {
            item.enabled = enable;
            
            if (!enable) {
                [item setSelected:NO];
            }
        }
    }
}

- (void)clearSelectedToolbarItems
{
    for (ZSSBarButtonItem *item in self.leftToolbar.items) {
        if (item.tag != kWPEditorViewControllerElementShowSourceBarButton) {
           [item setSelected:NO];
        }
    }
}

- (BOOL)hasSomeEnabledToolbarItems
{
    return !(self.enabledToolbarItems & ZSSRichTextEditorToolbarNone);
}

- (void)selectToolbarItemsForStyles:(NSArray*)styles
{
    NSArray *items = self.leftToolbar.items;
    
    for (UIBarButtonItem *item in items) {
        // Since we're using UIBarItem as negative separators, we need to make sure we don't try to
        // use those here.
        //
        if ([item isKindOfClass:[ZSSBarButtonItem class]]) {
            ZSSBarButtonItem* zssItem = (ZSSBarButtonItem*)item;
            
            if ([styles containsObject:zssItem.htmlProperty]) {
                zssItem.selected = YES;
            } else {
                zssItem.selected = NO;
            }
        }
    }
}

#pragma mark - Getters

- (UIBarButtonItem*)htmlBarButtonItem
{
    if (!_htmlBarButtonItem) {
        UIBarButtonItem* htmlBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"HTML"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:nil
                                                                              action:nil];
        
        UIFont * font = [UIFont boldSystemFontOfSize:10];
        NSDictionary * attributes = @{NSFontAttributeName: font};
        [htmlBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        htmlBarButtonItem.accessibilityLabel = NSLocalizedString(@"Display HTML",
                                                                 @"Accessibility label for display HTML button on formatting toolbar.");
        
        CGRect customButtonFrame = CGRectMake(0,
                                              0,
                                              WPEditorToolbarButtonWidth,
                                              WPEditorToolbarButtonHeight);
        
        WPEditorToolbarButton* customButton = [[WPEditorToolbarButton alloc] initWithFrame:customButtonFrame];
        [customButton setTitle:@"HTML" forState:UIControlStateNormal];
        customButton.normalTintColor = self.itemTintColor;
        customButton.selectedTintColor = self.selectedItemTintColor;
        customButton.reversesTitleShadowWhenHighlighted = YES;
        customButton.titleLabel.font = font;
        [customButton addTarget:self
                         action:@selector(showHTMLSource:)
               forControlEvents:UIControlEventTouchUpInside];
        
        htmlBarButtonItem.customView = customButton;
        
        _htmlBarButtonItem = htmlBarButtonItem;
    }
    
    return _htmlBarButtonItem;
}

- (UIView*)rightToolbarHolder
{
    UIView* rightToolbarHolder = _rightToolbarHolder;
    
    if (!rightToolbarHolder) {
        
        CGRect rightToolbarHolderFrame = CGRectMake(CGRectGetWidth(self.frame) - WPEditorToolbarButtonWidth,
                                                    0.0f,
                                                    WPEditorToolbarButtonWidth,
                                                    WPEditorToolbarHeight);
        rightToolbarHolder = [[UIView alloc] initWithFrame:rightToolbarHolderFrame];
        rightToolbarHolder.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        rightToolbarHolder.clipsToBounds = YES;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = rightToolbarHolder.bounds;
        FAKFontAwesome *ic = [FAKFontAwesome trashIconWithSize:20];
        
        [ic addAttribute:NSForegroundColorAttributeName value:[UIColor
                                                               colorWithRed:229.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1.0]];
        [btn.titleLabel setAttributedText:ic.attributedString];
        
        [btn addTarget:self action:@selector(btnMorePressed:) forControlEvents:UIControlEventTouchUpInside];
    
        [btn setAttributedTitle:ic.attributedString forState:UIControlStateNormal];
        [rightToolbarHolder addSubview:btn];
        
        _rightToolbarHolder = rightToolbarHolder;
    }
    
    return rightToolbarHolder;
}

- (void)btnMorePressed:(UIButton *)sender{
    [self.delegate btnMorePressed:sender];
}


- (UIBarButtonItem*)moreBarButtonItem
{
    if (!_htmlBarButtonItem) {
        UIBarButtonItem* htmlBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"HTML"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:nil
                                                                              action:nil];
       
        FAKFontAwesome *ic = [FAKFontAwesome ellipsisVIconWithSize:20];
        
        [ic addAttribute:NSForegroundColorAttributeName value:[UIColor
                                                                     whiteColor]];
//        NSDictionary * attributes = @{NSFontAttributeName: ic};
//        [htmlBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
//        htmlBarButtonItem.accessibilityLabel = NSLocalizedString(@"Display HTML",
//                                                                 @"Accessibility label for display HTML button on formatting toolbar.");
//        
        CGRect customButtonFrame = CGRectMake(0,
                                              0,
                                              WPEditorToolbarButtonWidth,
                                              WPEditorToolbarButtonHeight);
        
        WPEditorToolbarButton* customButton = [[WPEditorToolbarButton alloc] initWithFrame:customButtonFrame];
        [customButton setTitle:@"HTML" forState:UIControlStateNormal];
        customButton.normalTintColor = [UIColor whiteColor];//self.itemTintColor;
        customButton.selectedTintColor = [UIColor whiteColor];//self.selectedItemTintColor;
        customButton.reversesTitleShadowWhenHighlighted = YES;
        customButton.titleLabel.attributedText = [ic attributedString];
        [customButton addTarget:self
                         action:@selector(showHTMLSource:)
               forControlEvents:UIControlEventTouchUpInside];
        
        htmlBarButtonItem.customView = customButton;
        
        _htmlBarButtonItem = htmlBarButtonItem;
    }
    
    return _htmlBarButtonItem;
}



#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (self.backgroundColor != backgroundColor) {
        super.backgroundColor = backgroundColor;
        
        self.leftToolbar.barTintColor = backgroundColor;
        self.rightToolbar.barTintColor = backgroundColor;
    }
}

- (void)setBorderColor:(UIColor *)borderColor
{
    if (_borderColor != borderColor) {
        _borderColor = borderColor;
        
        self.topBorderView.backgroundColor = borderColor;
        self.rightToolbarDivider.backgroundColor = borderColor;
    }
}

- (void)setItems:(NSArray*)items
{
    if (_items != items) {
        _items = [items copy];
        
        [self reloadItems];
    }
}

- (void)setItemTintColor:(UIColor *)itemTintColor
{
    _itemTintColor = itemTintColor;
    
    for (UIBarButtonItem *item in self.leftToolbar.items) {
        item.tintColor = _itemTintColor;
    }
    
    if (self.htmlBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.htmlBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        htmlButton.normalTintColor = itemTintColor;
        self.htmlBarButtonItem.tintColor = itemTintColor;
    }
}

- (void)setSelectedItemTintColor:(UIColor *)selectedItemTintColor
{
    _selectedItemTintColor = selectedItemTintColor;

    if (self.htmlBarButtonItem) {
        WPEditorToolbarButton* htmlButton = (WPEditorToolbarButton*)self.htmlBarButtonItem.customView;
        NSAssert([htmlButton isKindOfClass:[WPEditorToolbarButton class]],
                 @"Expected to have an HTML button of class WPEditorToolbarButton here.");
        
        htmlButton.selectedTintColor = selectedItemTintColor;
    }
}

#pragma mark - Temporary: added to make the refactor easier, but should be removed at some point

- (void)showHTMLSource:(UIBarButtonItem *)barButtonItem
{
    [self.delegate editorToolbarView:self showHTMLSource:barButtonItem];
}

@end
