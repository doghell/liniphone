//
//  NotificationTester.m
//  linphone
//
//  Created by Gautier Pelloux-Prayer on 10/03/16.
//
//

#import "NotificationTester.h"

@implementation NotificationTester

#if !TARGET_IPHONE_SIMULATOR

- (void)beforeAll {
	[super beforeAll];
	[self switchToValidAccountIfNeeded];
}

// static void hack_message_received(LinphoneCore *lc, LinphoneChatRoom *room, LinphoneChatMessage *message) {
//
//	[(__bridge LinphoneManager *)linphone_core_get_user_data(lc) onMessageReceived:lc room:room message:message];
//}

- (void)testChatRemoteNotification {
	[tester tapViewWithAccessibilityLabel:@"Chat"];
	[self removeAllRooms];

	// set custom user agent so that server send only push notifications (no messages)
	const char *old_user_agent = linphone_core_get_user_agent(LC);
	linphone_core_set_user_agent(LC, "only-push-notifications", "1");

	const LinphoneAddress *addr =
		linphone_proxy_config_get_identity_address(linphone_core_get_default_proxy_config(LC));

	LinphoneChatMessage *msg = linphone_chat_room_create_message(linphone_core_get_chat_room(LC, addr), "push message");
	linphone_chat_room_send_chat_message(linphone_core_get_chat_room(LC, addr), msg);
	linphone_core_set_network_reachable(LC, NO);

	// it can take several seconds to receive the remote push notification...
	int timeout = 5;
	while (timeout > 0) {
		[tester tryFindingViewWithAccessibilityLabel:@"Contact name, Message" error:nil];
		timeout--;
	}
	[tester waitForViewWithAccessibilityLabel:@"Contact name, Message"
										value:[NSString stringWithFormat:@"%@, push message (1)", self.me]
									   traits:UIAccessibilityTraitStaticText];

	linphone_core_set_user_agent(LC, old_user_agent, "1");
}

#endif

@end
