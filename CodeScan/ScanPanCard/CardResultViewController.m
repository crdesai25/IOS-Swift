//
//  CardResultViewController.m
//  AccuraSDK
//
//  *********************** file use to display result after send image of pan card and aadhar card to server ****************


#import "CardResultViewController.h"
#import "resultTableViewCell.h"
#import "PlacePanCardViewController.h"
//D_//#import "PlaceAdharViewController.h"
#import "WebServiceUrl.h"
#import "ImageViewController.h"

@interface CardResultViewController ()
{
    resultTableViewCell *cell;
    NSString *uniqStr;
    int row;

}
@end

@implementation CardResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@",_dict);
    docImg.image = _docImgPass;
   
    imgPhoto.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_dict valueForKey:@"scan_image"]]]];
//    imgPhoto.layer.cornerRadius = imgPhoto.frame.size.width / 2;
//    imgPhoto.clipsToBounds = YES;
    if ([_isFrom isEqualToString:@"4"])
    {
        cons_height.constant = 0;
        view_heg.constant = 640;

    }
    else
    {
        cons_height.constant = 120;
        view_heg.constant = 800;
    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender
{
    [_delegate sendDataToA:true];
    [self.navigationController popViewControllerAnimated:NO];
   
}

- (IBAction)saveAction:(id)sender
{
}
- (void)viewWillAppear:(BOOL)animated
{
//    imgPhoto.layer.cornerRadius = imgPhoto.frame.size.width / 2;
//    imgPhoto.layer.masksToBounds = YES;
}
#pragma  ------------------tableview delegate -----------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_isFrom isEqualToString:@"4"])
    {
        row = 4;
        return 3;
    }
    else if ([_isFrom isEqualToString:@"2"])
    {
        row = 7;
        return 6;
    }
    else
    {
        row = 7;
        return 6;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[resultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if ([_isFrom isEqualToString:@"4"])
    {
        switch (indexPath.row)
        {
            case 0:
            {
                cell.lblName.text=@"DOCUMENT";
                cell.lblValue.text=[_dict valueForKey:@"card"];
            }
                 break;
            case 1:
            {
                
                cell.lblName.text=@"ADDRESS";
                cell.lblValue.text=[_dict valueForKey:@"address"];
            }
                 break;
            case 2:
            {
                
                cell.lblName.text=@"COUNTRY";
                cell.lblValue.text=@"IND";
            }
                 break;
        }
        return cell;
    }
    else if ([_isFrom isEqualToString:@"2"])
    {
        switch (indexPath.row)
        {
            case 0:
            {
                cell.lblName.text=@"DOCUMENT";
                cell.lblValue.text=[_dict valueForKey:@"card"];
            }
                break;
            case 1:
            {
                cell.lblName.text=@"LAST NAME";
                cell.lblValue.text=[_dict valueForKey:@"second_name"];
            }
                break;
            case 2:
            {
                cell.lblName.text=@"FIRST NAME";
                cell.lblValue.text=[_dict valueForKey:@"name"];
            }
                break;
            case 3:
            {
                cell.lblName.text=@"PAN CARD NO";
                cell.lblValue.text=[_dict valueForKey:@"pan_card_no"];
               
            }
                break;
            case 4:
            {
                cell.lblName.text=@"DATE OF BIRTH";
                cell.lblValue.text=[_dict valueForKey:@"date of birth"];
            }
                break;
            case 5:
            {
                
                cell.lblName.text=@"COUNTRY";
                cell.lblValue.text=@"IND";
            }
                break;
                
        }
    }
    
    else
    {
        switch (indexPath.row)
        {
            case 0:
                {
                    cell.lblName.text=@"DOCUMENT";
                    cell.lblValue.text=[_dict valueForKey:@"card"];
                }
                break;
            case 1:
                {
                    cell.lblName.text=@"FIRST NAME";
                    cell.lblValue.text=[_dict valueForKey:@"name"];
                }
                break;
            case 2:
                {
                    cell.lblName.text=@"AADHAR CARD NO";
                    cell.lblValue.text=[_dict valueForKey:@"aadhar_card_no"];

                }
                break;
            case 3:
                {
                    cell.lblName.text=@"DATE OF BIRTH";
                    cell.lblValue.text=[_dict valueForKey:@"date of birth"];
                }
                break;
            case 4:
            {
                cell.lblName.text=@"SEX";
                cell.lblValue.text=[_dict valueForKey:@"sex"];
            }
                break;
            case 5:
            {
                
                cell.lblName.text=@"COUNTRY";
                cell.lblValue.text=@"IND";
            }
                break;
        }
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_isFrom isEqualToString:@"4"])
    {
         view_heg.constant = row * 50 + 320 + 100;
        if (indexPath.row == 0 || indexPath.row == 2)
        {
            return 50;
        }
        else
        {
            return 150;
        }
    }
    else
    {
        view_heg.constant = row * 50 + 440;
        return 50;
    }
}

//- (void)saveImage:(UIImage*)saveImg:(NSString*)imageName {
- (void)saveImageatDoc:(UIImage*)saveImg imagename:(NSString*)imageName {

    NSData *imageData = UIImagePNGRepresentation(saveImg); //convert image into .png format.
    
    NSFileManager *fileManager =
    
    [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil];
    
    NSLog(@"image saved");
    
}
- (NSString *)imageToNSString:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
-(NSString *)dateToString:(NSString *)dateStr
{
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    return [dateFormat stringFromDate:date];
    
}
@end
