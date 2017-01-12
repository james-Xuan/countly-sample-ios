// EventCreatorViewController.m
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.

#import "EventCreatorViewController.h"
#import "Countly.h"

@interface ToolBarTextField : UITextField
@end

@implementation ToolBarTextField
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        UIBarButtonItem *flexibleSpace = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        UIBarButtonItem* btn_OK = [UIBarButtonItem.alloc initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(onClick_OK:)];
        [btn_OK setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.whiteColor} forState:UIControlStateNormal];

        UIToolbar* toolbar = UIToolbar.new;
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        toolbar.items = @[flexibleSpace, btn_OK];
        [toolbar sizeToFit];

        self.inputAccessoryView = toolbar;
    }

    return self;
}


- (void)onClick_OK:(id)sender
{
    [self.delegate textFieldShouldReturn:self];
}

@end



@interface EventCreatorViewController ()
{
    NSMutableArray* segmentation;
}
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@end

@implementation EventCreatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Create Event";
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onClick_cancel:)];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.redColor} forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithTitle:@"Record" style:UIBarButtonItemStylePlain target:self action:@selector(onClick_record:)];

    segmentation = NSMutableArray.new;

    self.tableView.tableFooterView = UIView.new;
}

- (void)onClick_cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)onClick_record:(id)sender
{
    UITextField* txt_name = [self.tableView viewWithTag:101];
    UITextField* txt_count = [self.tableView viewWithTag:102];
    UITextField* txt_sum = [self.tableView viewWithTag:103];
    UITextField* txt_duration = [self.tableView viewWithTag:104];

    if(!txt_name.text.length)
    {
        [txt_name becomeFirstResponder];
        return;
    }

    NSString* name = [txt_name.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    NSInteger count = txt_count.text.integerValue;
    double sum = [txt_sum.text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
    double duration = [txt_duration.text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
    NSMutableDictionary* segm = segmentation.count ? NSMutableDictionary.new : nil;
    for (NSDictionary* dict in segmentation)
        segm[dict[@"k"]] = dict[@"v"];

    [Countly.sharedInstance recordEvent:name segmentation:segm count:count sum:sum duration:duration];

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = 0;

    switch (indexPath.section)
    {
        case 0: height = 310; break;
        case 1: height = 44; break;
    }

    return height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;

    switch (section)
    {
        case 0: numberOfRows = 1; break;
        case 1: numberOfRows = segmentation.count + 1; break;
    }

    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = nil;

    switch (indexPath.section)
    {
        case 0: identifier = @"EventBasicValues"; break;
        case 1: identifier = @"EventSegmentation";
                if(indexPath.row == segmentation.count)
                    identifier = @"EventSegmentationAdd";
        break;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if(indexPath.section == 1 && indexPath.row != segmentation.count)
    {
        ((UILabel *)[cell viewWithTag:201]).text = segmentation[indexPath.row][@"k"];
        ((UILabel *)[cell viewWithTag:202]).text = segmentation[indexPath.row][@"v"];
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        if(indexPath.row == segmentation.count)
        {
            UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Add Segment" message:@"Enter segmentation key and value:" preferredStyle:UIAlertControllerStyleAlert];

            [alertController addTextFieldWithConfigurationHandler:^(UITextField * textField)
            {
                textField.placeholder = @"key";
            }];

            [alertController addTextFieldWithConfigurationHandler:^(UITextField * textField)
            {
                textField.placeholder = @"value";
            }];


            UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancel];
        
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
            {
                NSString* key = alertController.textFields[0].text;
                NSString* value = alertController.textFields[1].text;
                if(key.length && value.length)
                {
                    [segmentation addObject:@{@"k":key,@"v":value}];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }];

            [alertController addAction:ok];
        
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            [segmentation removeObjectAtIndex:indexPath.row];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
