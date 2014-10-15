//
//  RHEStationDetailsViewController.m
//  Vindsiden
//
//  Created by Ragnar Henriksen on 16.05.12.
//  Copyright (c) 2012 Shortcut AS. All rights reserved.
//

#import "RHEStationDetailsViewController.h"
#import "VindsidenKit.h"

#import "UIFontDescriptor+textStyle.h"
#import "UIFont+textStyle.h"

#import <JTSImageViewController/JTSImageViewController.h>


@interface RHEStationDetailsViewController ()

@property (strong, nonatomic) NSRegularExpression *regexRemoveHTMLTags;

@end

@implementation RHEStationDetailsViewController
{
    NSArray *_buttons;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.station.stationName;

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, -6.0, 320.0, 30)];
    v.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableFooterView = v;

    _buttons = @[NSLocalizedString(@"Go to yr.no", nil), NSLocalizedString(@"View in Maps", nil)];

    if ( [self.station.webCamImage length] > 0 ) {
        _buttons = [_buttons arrayByAddingObject:NSLocalizedString(@"Show Camera", nil)];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)preferredContentSizeChanged:(NSNotification *)aNotification
{
    for ( UIButton *button in self.tableView.tableFooterView.subviews ) {
        button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }

    [self.view setNeedsLayout];
    [self.tableView reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( 0 == section ) {
        return 6;
    } else {
        return [_buttons count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StationDetailsCell";
    static NSString *ButtonCellIdentifier = @"ButtonCell";

    UITableViewCell *cell = nil;

    if ( 0 == indexPath.section ) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [self configureCell:cell atIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
        cell.textLabel.textColor = self.view.tintColor;
        cell.textLabel.text = [_buttons objectAtIndex:indexPath.row];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont preferredFontForTextStyle:[[cell.textLabel.font fontDescriptor] objectForKey:@"NSCTFontUIUsageAttribute"]];
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:[[cell.detailTextLabel.font fontDescriptor] objectForKey:@"NSCTFontUIUsageAttribute"]];
}


- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch ( indexPath.row )
    {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Name", nil);
            cell.detailTextLabel.text = _station.stationName;
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Place", nil);
            cell.detailTextLabel.text = _station.city;
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Copyright", nil);
            cell.detailTextLabel.text = _station.copyright;
            break;
        case 3:
        {
            NSString *tmp = [[[self regexRemoveHTMLTags] stringByReplacingMatchesInString:_station.stationText
                                                                                  options:0
                                                                                    range:NSMakeRange(0, [_station.stationText length])
                                                                             withTemplate:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

            cell.textLabel.text = NSLocalizedString(@"Info", nil);
            cell.detailTextLabel.text = tmp;
        }
            break;
        case 4:
            cell.textLabel.text = NSLocalizedString(@"Status", nil);
            cell.detailTextLabel.text = [[self regexRemoveHTMLTags] stringByReplacingMatchesInString:_station.statusMessage
                                                                                             options:0
                                                                                               range:NSMakeRange(0, [_station.statusMessage length])
                                                                                        withTemplate:@""];
            break;
        case 5:
            cell.textLabel.text = NSLocalizedString(@"Camera", nil);
            cell.detailTextLabel.text = [[self regexRemoveHTMLTags] stringByReplacingMatchesInString:_station.webCamText
                                                                                             options:0
                                                                                               range:NSMakeRange(0, [_station.webCamText length])
                                                                                        withTemplate:@""];
            break;
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect labelBounds = CGRectZero;
    NSDictionary *fontAtts = @{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]};

    switch ( indexPath.row )
    {
        case 0:
            labelBounds = [_station.stationName boundingRectWithSize:CGSizeMake( 150.0, 400.0)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:fontAtts
                                                             context:nil];
            break;
        case 1:
            labelBounds = [_station.city boundingRectWithSize:CGSizeMake( 150.0, 400.0)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:fontAtts
                                                      context:nil];
            break;
        case 2:
            labelBounds = [_station.copyright boundingRectWithSize:CGSizeMake( 150.0, 400.0)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:fontAtts
                                                           context:nil];
            break;
        case 3:
        {
            NSString *tmp = [[[self regexRemoveHTMLTags] stringByReplacingMatchesInString:_station.stationText
                                                                                 options:0
                                                                                   range:NSMakeRange(0, [_station.stationText length])
                                                                            withTemplate:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            labelBounds = [tmp boundingRectWithSize:CGSizeMake( 150.0, 800.0)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:fontAtts
                                            context:nil];
        }
            break;
        case 4:
            labelBounds = [_station.statusMessage boundingRectWithSize:CGSizeMake( 150.0, 400.0)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:fontAtts
                                                               context:nil];
            break;
        case 5:
            if ( [_station.webCamText length] > 0 ) {
                labelBounds = [[[self regexRemoveHTMLTags] stringByReplacingMatchesInString:_station.webCamText
                                                                                    options:0
                                                                                      range:NSMakeRange(0, [_station.webCamText length])
                                                                               withTemplate:@""]
                               boundingRectWithSize:CGSizeMake( 150.0, 400.0)
                               options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:fontAtts
                               context:nil];
            }
            break;
    }

    return MAX( 50.0, ceilf(CGRectGetHeight(labelBounds)));
}



#pragma mark - Table view delegate


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 1);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( 0 == indexPath.section ) {
        if ( 1 == indexPath.row ) {
            [self showMap:nil];
        }
    } else {
        if ( 0 == indexPath.row ) {
            [self gotoYR:nil];
        } else if ( 1 == indexPath.row ) {
            [self showMap:nil];
        } else {
            [self showCamera:nil];
        }

    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -


- (NSRegularExpression *) regexRemoveHTMLTags
{
    if ( _regexRemoveHTMLTags ) {
        return _regexRemoveHTMLTags;
    }

    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<[^>]+>)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    _regexRemoveHTMLTags = regex;
    return regex;
}


#pragma mark - Actions


- (void)done:(id)sender
{
    [_delegate rheStationDetailsViewControllerDidFinish:self];
}


- (IBAction)gotoYR:(id)sender
{
    NSURL *url = [NSURL URLWithString:[_station.yrURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}


- (IBAction)showMap:(id)sender
{
    CLLocationCoordinate2D spotCord = CLLocationCoordinate2DMake( [_station.coordinateLat doubleValue], [_station.coordinateLon doubleValue]);
    
    NSMutableString *query = [NSMutableString stringWithString:@"http://maps.apple.com/?t=h&z=10"];
    
    if ( spotCord.latitude > 0 || spotCord.longitude > 0 ) {
        [query appendFormat:@"&ll=%f,%f", spotCord.latitude, spotCord.longitude];
    }
    
    if ( [_station.city length] > 0 ) {
        [query appendFormat:@"&q=%@", _station.city];
    } else {
        [query appendFormat:@"&q=%@", _station.stationName];
    }
    
    NSURL *url = [NSURL URLWithString:[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}


- (IBAction)showCamera:(id)sender
{
    //[self performSegueWithIdentifier:@"ShowWebCam" sender:nil];
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.imageURL = [NSURL URLWithString:self.station.webCamImage];
    imageInfo.referenceRect = [sender frame];
    imageInfo.referenceView = self.view;

    JTSImageViewController *controller = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                      mode:JTSImageViewControllerMode_Image
                                                                           backgroundStyle:JTSImageViewControllerBackgroundStyle_ScaledDimmedBlurred];

    [controller showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}


@end
