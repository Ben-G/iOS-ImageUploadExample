//
//  ViewController.m
//  ImageUploadExample
//
//  Created by Benjamin Encz on 15/09/14.
//  Copyright (c) 2014 MakeSchool. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,  NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSMutableData *downloadData;
@property (weak, nonatomic) IBOutlet UILabel *downloadProgress;

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
  
  self.downloadData = [NSMutableData data];
  NSURLConnection *imageUploadConnection = [NSURLConnection connectionWithRequest:request delegate:self];
  [imageUploadConnection start];
  
//  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    NSLog(@"%@", responseDictionary);
//  }];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
  
  CGFloat percentage = totalBytesWritten / totalBytesExpectedToWrite;
  NSInteger progress = percentage * 100;
  self.downloadProgress.text = [NSString stringWithFormat:@"%d %%", progress];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.downloadData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:self.downloadData options:0 error:nil];
  self.downloadProgress.text = responseDictionary[@"id"];
}

@end