//
//  ViewController.m
//  ImageUploadExample
//
//  Created by Benjamin Encz on 15/09/14.
//  Copyright (c) 2014 MakeSchool. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSLog(@"%@", NSHomeDirectory());
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(id)sender {
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:pickerController animated:YES completion:nil];
  }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *capturedImage = info[UIImagePickerControllerOriginalImage];
  self.imageView.image = capturedImage;
  [self dismissViewControllerAnimated:YES completion:nil];
  
  // upload image
  NSURL *url = [NSURL URLWithString:@"http://10.0.31.241:3000/image"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
  
  [request setHTTPMethod:@"POST"]; // 1
  
  NSString *boundary = @"YOUR_BOUNDARY_STRING";
  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
  [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
  
  NSMutableData *body = [NSMutableData data];
  
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@.jpg\"\r\n", @"testImage"] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:UIImageJPEGRepresentation(capturedImage, 1.0)];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  
  [request setHTTPBody:body];
  
  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"%@", responseDictionary);
  }];
}

@end