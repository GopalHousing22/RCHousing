//
//  RemoteConfigMapper.swift
//  housing
//
//  Created by Gopal on 31/08/23.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation

class RemoteConfigMapper {
    static func getModuleMapping(moduleName: String = "") -> [String] {
        switch moduleName.lowercased() {
        case "edge":
            return Edge
        case "seller":
            return Seller
        case "news":
            return News
        case "calculator":
            return Calculator
        default:
            return []
        }
    }
    
    static let Edge = [
        "new_truecaller_card",
        "city_data_version",
        "rent_relevance_v2",
        "new_serp_card_cta_seller",
        "use_khoj_buy_filter_api",
        "use_khoj_pg_filter_api",
        "show_optimized_generic_text_input",
        "enable_value_present_to_v5",
        "app_exit_time",
        "sentry_trace_rate_staging",
        "sentry_trace_rate_production",
        "sentry_error_tracking",
        "cta_experiment_project",
        "cta_experiment_resale",
        "cta_experiment_rent",
        "cta_experiment_pg",
        "contact_cta_config",
        "whatsapp_cta_config",
        "otp_position",
        "show_truecaller",
        "voice_icon_placements",
        "enable_trace",
        "verify_non_tc_users",
        "show_request_image_cta",
        "seller_flow_enabled",
        "mobile_no_picker_exp",
        "show_np_multicard_exp",
        "blank_experiment_app",
        "enable_bill_payments",
        "show_creditPay_flow",
        "credpay_dark_theme_visible",
        "rent_protect_flow_new",
        "rent_protect_insurance_experiment",
        "show_hp_blocker",
        "hp_pricing_exp",
        "poc_safer_access_v2",
        "pay_again_exp_variant",
        "hp_lb_variant_revamp",
        "hp_promo_exp",
        "rp_repeat_user_opt_in_exp",
        "hp_serp_hook",
        "hp_pdp_hook",
        "hp_crf_hook",
        "hp_serp_hook_timer",
        "hp_offers_data",
        "referral_share_variant",
        "is_digio_user",
        "hp_blocker_serp_type",
        "poc_hook_exp_buy",
        "hp_post_paywall_timer",
        "poc_hook_pdp",
        "poc_hook_crf",
        "poc_hook_serp",
        "poc_hook_homepage_bar",
        "poc_hook_news",
        "poc_hook_seller_homepage",
        "poc_hook_seller_profile",
        "poc_hook_quicklinks",
        "cyber_insurance_weight",
        "enable_cyber_insurance",
        "poc_revamp_v2",
        "onboarding_addon",
        "poc_revamp_offer",
        "hp_home_page_header_hook",
        "hp_sachet_cross_paywall",
        "hp_sachet_razorpay_dropoff",
        "hp_sachet_lp_banner",
        "hp_guided_flow_exp",
        "enable_ins_reverse_exp",
        "insurance_with_hp",
        "ins_with_hp_prod_type_list",
        "insurance_service_page",
        "show_instant_loan",
        "show_rnpl_share",
        "is_poc_intent_user",
        "home_search_limit",
        "milestone_exp",
        "milestone_poc_home_exp",
        "show_stories",
        "show_poc_introbox"
    ]
    
    static let Seller = [
        "new_truecaller_cards",
        "city_data_version",
        "search_nearby_homepage",
        "otp_position",
        "show_ringlerr_card",
        "new_serp_card_cta_seller",
        "show_account_settings",
        "query_support",
        "post_crf_compare_properties",
        "show_optimized_generic_text_input",
        "show_optimized_generic_comps",
        "rent_relevance_v2",
        "show_housing_chat_option_leads",
        "ml_based_similar_properties",
        "use_khoj_buy_filter_api",
        "use_khoj_pg_filter_api",
        "show_markup_price_on_order_review",
        "enable_self_verification",
        "assurance_banner_experiment",
        "self_verification_enabled_cities",
        "srp_paid_projects_enabled",
        "enable_housing_direct_v2",
        "housing_zero_cities_v2",
        "contact_cta_config",
        "show_in_app_notifications",
        "otp_position",
        "show_truecaller",
        "seller_listingpage_hook",
        "seller_listing_delete_hook",
        "voice_icon_placements",
        "enable_trace",
        "verify_non_tc_users",
        "contact_customer_support_number",
        "app_exit_time",
        "mobile_no_picker_exp",
        "show_np_multicard_exp",
        "sentry_trace_rate_staging",
        "sentry_trace_rate_production",
        "sentry_error_tracking",
        "bonus_lead_expiry_time",
        "poc_hook_crf",
        "poc_hook_serp",
        "poc_hook_homepage_bar",
        "poc_hook_news",
        "poc_hook_seller_homepage",
        "poc_hook_seller_profile",
        "poc_hook_quicklinks",
        "reverse_marketplace_enhacement"
    ]
    
    static let News = [
        "sentry_trace_rate_staging",
        "sentry_trace_rate_production",
        "sentry_error_tracking",
        "news_base_url",
        "poc_hook_news"
    ]
    
    static let Calculator = [
        "sentry_trace_rate_staging",
        "sentry_trace_rate_production",
        "sentry_error_tracking"
    ]
}

