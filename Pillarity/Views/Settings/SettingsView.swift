//
//  SettingsView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    // Current logged-in user (SwiftData)
    @Bindable var user: User
    @EnvironmentObject var session: AppSession

    // MARK: - Local settings state (later move these into a model)
    @State private var pushNotifications: Bool = true
    @State private var soundAlerts: Bool = true
    @State private var alertVolume: Double = 1.00
    @State private var vibration: Bool = true
    @State private var reminderFrequency: String = "Every 15 minutes"

    @State private var autoLock: Bool = false
    @State private var emergencyOverride: Bool = true

    @State private var ledIndicators: Bool = true
    @State private var ledColorTheme: String = "Blue"
    @State private var batteryLevel: Int = 87

//    @State private var darkMode: Bool = false
    @State private var language: String = "English"

    private let reminderOptions = [
        "Never",
        "Every 5 minutes",
        "Every 15 minutes",
        "Every 30 minutes",
        "Every hour"
    ]

    private let ledColorOptions = [
        "Blue", "Green", "Purple", "Red", "Teal"
    ]

    private let languageOptions = [
        "English", "Spanish", "French", "Hindi"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Account Type (from User model)
                SettingsCard {
                    SettingsHeader(
                        systemImage: "person.crop.circle",
                        title: "Account Type",
                        subtitle: "Your current account type"
                    )

                    SettingsValueRow(
                        title: "Account Type",
                        value: user.accountType.rawValue
                    )

                    SettingsValueRow(
                        title: "Email",
                        value: user.email
                    )
                }

                // MARK: - Notification Settings
                SettingsCard {
                    SettingsHeader(
                        systemImage: "bell",
                        title: "Notification Settings",
                        subtitle: "Manage how you receive medication reminders and alerts"
                    )

                    SettingsToggleRow(
                        title: "Push Notifications",
                        subtitle: "Receive notifications on your device",
                        isOn: $pushNotifications
                    )

                    Divider().padding(.vertical, 6)

                    SettingsToggleRow(
                        title: "Sound Alerts",
                        subtitle: "Play a sound when dose is due",
                        isOn: $soundAlerts
                    )

                    if soundAlerts {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Alert Volume")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            HStack {
                                Image(systemName: "speaker.wave.1")
                                    .font(.caption)

                                Slider(value: $alertVolume, in: 0...1)

                                Text("\(Int(alertVolume * 100))%")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 4)
                    }

                    Divider().padding(.vertical, 6)

                    SettingsToggleRow(
                        title: "Vibration",
                        subtitle: "Vibrate when dose is due",
                        isOn: $vibration
                    )

                    Divider().padding(.vertical, 6)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reminder Frequency")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Menu {
                            ForEach(reminderOptions, id: \.self) { option in
                                Button(option) { reminderFrequency = option }
                            }
                        } label: {
                            SettingsMenuLabel(title: reminderFrequency)
                        }

                        Text("How often to remind you after initial notification")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }

                // MARK: - Safety & Security
                SettingsCard {
                    SettingsHeader(
                        systemImage: "shield",
                        title: "Safety & Security",
                        subtitle: "Configure safety locks and access controls"
                    )

                    SettingsToggleRow(
                        title: "Auto-Lock Feature",
                        subtitle: "Automatically lock bottles between scheduled doses",
                        isOn: $autoLock
                    )

                    Divider().padding(.vertical, 6)

                    SettingsToggleRow(
                        title: "Emergency Override",
                        subtitle: "Allow manual unlock via app",
                        isOn: $emergencyOverride
                    )
                }

                // MARK: - Smart Bottle Settings
                SettingsCard {
                    SettingsHeader(
                        systemImage: "iphone",
                        title: "Smart Bottle Settings",
                        subtitle: "Configure your smart pill bottle hardware"
                    )

                    SettingsToggleRow(
                        title: "LED Light Indicators",
                        subtitle: "Light up bottle cap when dose is due",
                        isOn: $ledIndicators
                    )

                    if ledIndicators {
                        Divider().padding(.vertical, 6)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("LED Color Theme")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Menu {
                                ForEach(ledColorOptions, id: \.self) { color in
                                    Button(color) { ledColorTheme = color }
                                }
                            } label: {
                                SettingsMenuLabel(title: ledColorTheme)
                            }
                        }
                        .padding(.top, 2)
                    }

                    Divider().padding(.vertical, 6)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Battery Status")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        HStack {
                            Text("Current battery level")
                                .font(.subheadline)

                            Spacer()

                            Text("\(batteryLevel)%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        Text("Place bottle on charging base when battery is low")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }

                // MARK: - App Preferences
                SettingsCard {
                    SettingsHeader(
                        systemImage: "moon",
                        title: "App Preferences",
                        subtitle: "Customize your app experience"
                    )

                    SettingsToggleRow(
                        title: "Dark Mode",
                        subtitle: "Use dark theme for the app",
                        isOn: $session.isDarkModeEnabled
                    )

                    Divider().padding(.vertical, 6)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Language")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Menu {
                            ForEach(languageOptions, id: \.self) { lang in
                                Button(lang) { language = lang }
                            }
                        } label: {
                            SettingsMenuLabel(title: language)
                        }
                    }
                    .padding(.top, 2)
                }

                // MARK: - Actions
                VStack(spacing: 12) {
                    PillarityButton(title: "Export Data") {
                        // TODO: hook up export
                    }

                    PillarityButton(title: "Contact Support") {
                        // TODO: hook up support
                    }

                    PillarityButton(title: "Log Out", style: .destructive) {
                        session.logout()
                    }
                    
                    Text("Pillarity v1.0.0")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
        }
//        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
