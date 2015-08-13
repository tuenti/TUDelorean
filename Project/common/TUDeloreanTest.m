//
//  TUDeloreanTest.m
//  TUDelorean
//
//  Copyright 2013 Tuenti Technolgies S.L.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TUDelorean.h"
#import <XCTest/XCTest.h>
#import <SenTestingKit/SenTestingKit.h>

#define TUPASTE(x, y) x ## y
#define TUPASTE2(x, y) TUPASTE(x, y)
#define TUAssertDateEquals(obtained, expected, description) \
	NSTimeInterval TUPASTE2(expectedInterval, __LINE__) = [(expected) timeIntervalSinceReferenceDate]; \
	NSTimeInterval TUPASTE2(obtainedInterval, __LINE__) = [(obtained) timeIntervalSinceReferenceDate]; \
	XCTAssertEqualWithAccuracy(TUPASTE2(obtainedInterval, __LINE__), TUPASTE2(expectedInterval, __LINE__), 1.0, description);


@interface TUDeloreanTest : XCTestCase
@end

@implementation TUDeloreanTest
{
	NSCalendar *_calendar;
	NSDate *_clockTowerInauguration;
	NSDate *_enchantmentUnderTheSeaDance;
	NSDate *_jaws19Premiere;
}

- (void)setUp
{
	_calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];

	dateComponents.year = 1955;
	dateComponents.month = 11;
	dateComponents.day = 12;
	_enchantmentUnderTheSeaDance = [_calendar dateFromComponents:dateComponents];

	dateComponents.year = 1885;
	dateComponents.month = 9;
	dateComponents.day = 5;
	_clockTowerInauguration = [_calendar dateFromComponents:dateComponents];

	dateComponents.year = 2015;
	dateComponents.month = 10;
	dateComponents.day = 16;
	_jaws19Premiere = [_calendar dateFromComponents:dateComponents];
}

- (void)tearDown
{
	_calendar = nil;
	[TUDelorean backToThePresent];
	[super tearDown];
}

- (void)test_timeTravelTo_should_travel_through_time
{
	[TUDelorean timeTravelTo:_enchantmentUnderTheSeaDance];
	TUAssertDateEquals([NSDate date], _enchantmentUnderTheSeaDance, @"now should be the Enchantment Under The Sea Dance");
}

- (void)test_timeTravelTo_should_travel_to_the_future
{
	[TUDelorean timeTravelTo:_jaws19Premiere];
	TUAssertDateEquals([[NSDate alloc] initWithTimeIntervalSinceNow:0], _jaws19Premiere, @"now should be the Jaws 19 premiere");
}

- (void)test_timeTravelTo_should_travel_through_time_several_times
{
	[TUDelorean timeTravelTo:_enchantmentUnderTheSeaDance];
	[TUDelorean timeTravelTo:_clockTowerInauguration];
	TUAssertDateEquals([[NSDate alloc] init], _clockTowerInauguration, @"now should be the Clock Tower Inauguration");
}

- (void)test_timeTravelToBlock_should_travel_back_in_time
{
	NSDate *realDate = [NSDate date];
	[TUDelorean timeTravelTo:_enchantmentUnderTheSeaDance block:^(NSDate *date) {
		TUAssertDateEquals(date, _enchantmentUnderTheSeaDance, @"now should be the Enchantment Under The Sea Dance");
	}];
	TUAssertDateEquals([[NSDate alloc] init], realDate, @"now should be the present");
}

- (void)test_timeTravelToBlock_should_nest_correctly_travels_and_jump_backs_in_time
{
	[TUDelorean timeTravelTo:_enchantmentUnderTheSeaDance block:^(NSDate *date1) {
		TUAssertDateEquals(date1, _enchantmentUnderTheSeaDance, @"now should be the Enchantment Under The Sea Dance");
		[TUDelorean timeTravelTo:_clockTowerInauguration block:^(NSDate *date2) {
			TUAssertDateEquals(date2, _clockTowerInauguration, @"now should be the Clock Tower Inauguration");
		}];
	}];
}

- (void)test_timeTravelToBlock_should_not_fail_if_other_change_is_done_inside_the_block
{
	NSDate *realDate = [NSDate date];
	[TUDelorean timeTravelTo:_enchantmentUnderTheSeaDance block:^(NSDate *date) {
		[TUDelorean timeTravelTo:_clockTowerInauguration];
		TUAssertDateEquals([NSDate date], _clockTowerInauguration, @"now should be the Clock Tower Inauguration");
	}];
	TUAssertDateEquals([[NSDate alloc] init], realDate, @"now should be the present");
}

- (void)test_timeTravelToBlock_should_not_fail_if_backToThePresent_is_inside_the_block
{
	NSDate *realDate = [NSDate date];
	[TUDelorean timeTravelTo:_enchantmentUnderTheSeaDance block:^(NSDate *date) {
		[TUDelorean backToThePresent];
		TUAssertDateEquals([NSDate date], realDate, @"now should be the present");
	}];
	TUAssertDateEquals([[NSDate alloc] init], realDate, @"now should be the present (2)");
}

- (void)test_jump_should_travel_through_time
{
	NSDate *expected = [NSDate dateWithTimeIntervalSinceNow:60];
	[TUDelorean jump:60];
	TUAssertDateEquals([NSDate date], expected, @"now should be a minute into the future");
}

- (void)test_jump_should_travel_into_the_past
{
	NSDate *expected = [NSDate dateWithTimeIntervalSinceNow:-60];
	[TUDelorean jump:-60];
	TUAssertDateEquals([NSDate date], expected, @"now should be a minute ago");
}

- (void)test_jump_should_travel_several_times_using_previous_jump_as_starting_point
{
	NSDate *expected = [NSDate dateWithTimeIntervalSinceNow:90];
	[TUDelorean jump:60];
	[TUDelorean jump:30];
	TUAssertDateEquals([NSDate date], expected, @"now should be a minute and a half into the future");
}

- (void)test_jumpBlock_should_travel_back_in_time
{
	NSDate *realDate = [NSDate date];
	[TUDelorean jump:60 block:^(NSDate *date) {
		TUAssertDateEquals(date, [realDate dateByAddingTimeInterval:60], @"now should be a minute into the future");
	}];
	TUAssertDateEquals([[NSDate alloc] init], realDate, @"now should be the present");
}

- (void)test_jumpBlock_should_nest_correctly_jumps_and_jump_backs_in_time
{
	NSDate *realDate = [NSDate date];
	[TUDelorean jump:30 block:^(NSDate *date1) {
		TUAssertDateEquals(date1, [realDate dateByAddingTimeInterval:30], @"now should be half a minute into the future");
		[TUDelorean jump:60 block:^(NSDate *date2) {
			TUAssertDateEquals(date2, [realDate dateByAddingTimeInterval:90], @"now should be minute and a half into the future");
		}];
	}];
}

- (void)test_jumpBlock_should_not_fail_if_other_change_is_done_inside_the_block
{
	NSDate *realDate = [NSDate date];
	[TUDelorean jump:30 block:^(NSDate *date) {
		[TUDelorean jump:60];
		TUAssertDateEquals([NSDate date], [realDate dateByAddingTimeInterval:90], @"now should be minute and a half into the future");
	}];
	TUAssertDateEquals([[NSDate alloc] init], realDate, @"now should be the present");
}

- (void)test_jumpBlock_should_not_fail_if_backToThePresent_is_inside_the_block
{
	NSDate *realDate = [NSDate date];
	[TUDelorean timeTravelTo:_enchantmentUnderTheSeaDance block:^(NSDate *date) {
		[TUDelorean backToThePresent];
		TUAssertDateEquals([NSDate date], realDate, @"now should be the present");
	}];
	TUAssertDateEquals([[NSDate alloc] init], realDate, @"now should be the present (2)");
}

- (void)test_freeze_should_freeze_time
{
	[TUDelorean freeze:_enchantmentUnderTheSeaDance];
	XCTAssertEqualObjects([NSDate date], _enchantmentUnderTheSeaDance, @"now should be exactly the Enchantment Under The See Dance");
	XCTAssertEqual([NSDate timeIntervalSinceReferenceDate], [_enchantmentUnderTheSeaDance timeIntervalSinceReferenceDate], @"time interval since reference date should be exactly same as for the Enchantment Under The See Dance");
}

- (void)test_freeze_should_kept_the_last_frozen_time
{
	[TUDelorean freeze:_enchantmentUnderTheSeaDance];
	[TUDelorean freeze:_clockTowerInauguration];
	XCTAssertEqualObjects([NSDate date], _clockTowerInauguration, @"now should be exactly the Clock Tower Inauguration");
	XCTAssertEqual([NSDate timeIntervalSinceReferenceDate], [_clockTowerInauguration timeIntervalSinceReferenceDate], @"time interval since reference date should be exactly same as for the Clock Tower Inauguration");
}

- (void)test_freezeBlock_should_travel_back_in_time
{
	NSDate *today = [NSDate date];
	[TUDelorean freeze:_jaws19Premiere block:^(NSDate *date) {
		XCTAssertEqualObjects(date, _jaws19Premiere, @"now should be exactly the Jaws 19 Premiere");
	}];
	TUAssertDateEquals([[NSDate alloc] init], today, @"now should be the present");
}

- (void)test_freezeBlock_should_nest_correctly_several_freezes
{
	[TUDelorean freeze:_jaws19Premiere block:^(NSDate *date1) {
		XCTAssertEqualObjects(date1, _jaws19Premiere, @"now should be exactly the Jaws 19 Premiere");
		[TUDelorean freeze:_enchantmentUnderTheSeaDance block:^(NSDate *date2) {
			XCTAssertEqualObjects(date2, _enchantmentUnderTheSeaDance, @"now should be exactly the Enchantment Under The Sea Dance");
		}];
	}];
}

- (void)test_freezeBlock_should_not_fail_if_other_change_is_done_inside_the_block
{
	NSDate *realDate = [NSDate date];
	[TUDelorean freeze:_jaws19Premiere block:^(NSDate *date) {
		[TUDelorean freeze:_clockTowerInauguration];
		TUAssertDateEquals([NSDate date], _clockTowerInauguration, @"now should be the Clock Tower Inauguration");
	}];
	TUAssertDateEquals([[NSDate alloc] init], realDate, @"now should be the present");
}

- (void)test_freezeBlock_should_not_fail_if_backToThePresent_is_inside_the_block
{
	NSDate *realDate = [NSDate date];
	[TUDelorean freeze:_enchantmentUnderTheSeaDance block:^(NSDate *date) {
		[TUDelorean backToThePresent];
		TUAssertDateEquals([NSDate date], realDate, @"now should be the present");
	}];
	TUAssertDateEquals([[NSDate alloc] init], realDate, @"now should be the present (2)");
}

- (void)test_backToThePresent_should_stay_in_the_present_if_already_the_present
{
	NSDate *today = [NSDate date];
	[TUDelorean backToThePresent];
	TUAssertDateEquals([[NSDate alloc] init], today, @"now should be the present");
}

- (void)test_backToThePresent_should_go_to_the_present_if_not_in_the_present
{
	NSDate *today = [NSDate date];
	[TUDelorean timeTravelTo:_enchantmentUnderTheSeaDance];
	[TUDelorean backToThePresent];
	TUAssertDateEquals([[NSDate alloc] init], today, @"now should be the present");
}

- (void)test_backToThePresent_should_go_all_the_way_to_the_present_after_several_jumps
{
	NSDate *today = [NSDate date];
	[TUDelorean timeTravelTo:_enchantmentUnderTheSeaDance];
	[TUDelorean timeTravelTo:_clockTowerInauguration];
	[TUDelorean backToThePresent];
	TUAssertDateEquals([[NSDate alloc] init], today, @"now should be the present");
}

@end
