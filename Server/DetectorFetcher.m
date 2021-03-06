//
//  DetectorDownloader.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 16/09/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "DetectorFetcher.h"
#import "Detector.h"
#import "ConstantsServer.h"
#import "Reachability+DetectMe.h"


@interface DetectorFetcher()
{
    NSMutableData *_responseData;
}

@end


@implementation DetectorFetcher


#pragma mark -
#pragma mark Initialization

+ (NSURLRequest *) createRequestForURLString:(NSString *) requestURLString
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    return request;
}

#pragma mark -
#pragma mark Public Methods

- (void) fetchDetectorsASync
{
    if(![Reachability isNetworkReachable])
        return;
    
    NSString *requestURLString = [NSString stringWithFormat:@"%@detectors/api/",SERVER_ADDRESS];
    NSURLRequest *request = [self.class createRequestForURLString:requestURLString];
    
    _responseData = [[NSMutableData alloc] init];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) fetchDetectorsASyncFromTimestamp:(int)timestamp
{
    if(![Reachability isNetworkReachable]){
        [self.delegate downloadError:@"Wifi is not activated"];
        return;
    }
    
    NSString *requestURLString = [NSString stringWithFormat:@"%@detectors/api/lastupdated/%d",SERVER_ADDRESS, timestamp];
    NSURLRequest *request = [self.class createRequestForURLString:requestURLString];
    
    _responseData = [[NSMutableData alloc] init];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


+ (NSArray *) fetchDetectorsSync
{
    
    if(![Reachability isNetworkReachable])
        return nil;
    
    NSString *requestURLString = [NSString stringWithFormat:@"%@detectors/api/",SERVER_ADDRESS];
    NSURLRequest *request = [self createRequestForURLString:requestURLString];
    
    NSError *error;
    NSURLResponse *response;
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    
    NSArray *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (error){
        NSLog(@"[%@ %@] Connection error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
        results = nil;
    }
    
    return results;
}

+ (NSArray *) fetchAnnotatedImagesSyncForDetector:(Detector *)detector
{
    if(![Reachability isNetworkReachable])
        return nil;
    
    
    NSString *requestURLString = [NSString stringWithFormat:@"%@detectors/api/annotatedimages/fordetector/%@/",SERVER_ADDRESS, detector.serverDatabaseID];
    NSURLRequest *request = [self createRequestForURLString:requestURLString];
    
    NSError *error;
    NSURLResponse *response;
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSArray *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (error) NSLog(@"[%@ %@] Connection error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    
    return results;
}

+ (NSData *) fetchSupportVectorsSyncForDetector:(Detector *)detector
{
    if(![Reachability isNetworkReachable])
        return nil;
    
    NSString *requestURLString = [NSString stringWithFormat:@"%@detectors/api/supportvectors/%@/",SERVER_ADDRESS, detector.serverDatabaseID];
    NSURLRequest *request = [self createRequestForURLString:requestURLString];
    
    NSError *error;
    NSURLResponse *response;
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) NSLog(@"[%@ %@] Connection error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    
    return jsonData;
}


#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate downloadError:error.localizedDescription];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSArray *detectorsJSON = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    
    // update the detectorID field that stores the id of the detector on the webserver database
    if (error != nil)
        [self.delegate downloadError:@"Request timed out."];
    else [self.delegate obtainedDetectors:detectorsJSON];
}

#pragma mark -
#pragma mark Private Methods

- (NSArray *) detectorsJSONToObjects:(NSArray *)detectorsJSON
{
    
    NSString *serverAdress = [NSString stringWithFormat:@"%@media/", SERVER_ADDRESS];
    NSMutableArray *detectors = [NSMutableArray arrayWithCapacity:detectorsJSON.count];
    for(NSDictionary *detectorJSON in detectorsJSON) {

        NSString *url = [NSString stringWithFormat:@"%@%@",serverAdress,[detectorJSON objectForKey:@"average_image"]];
        NSString *name = [detectorJSON objectForKey:@"name"];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, url,nil]
                                                         forKeys:[NSArray arrayWithObjects:@"name",@"url",nil]];
        [detectors addObject:dict];
    }
    
    return [NSArray arrayWithArray:detectors];
}


@end
