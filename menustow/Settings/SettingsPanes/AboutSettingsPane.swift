//
//  AboutSettingsPane.swift
//  menustow
//
//  Adapted from stonerl/Ice (my-build) by @stonerl.

import SwiftUI

struct AboutSettingsPane: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var updatesManager: UpdatesManager
    @Environment(\.openURL) private var openURL
    @State private var showingAcknowledgements = false

    private var contributeURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://github.com/lswank/menustow")!
    }

    private var issuesURL: URL {
        contributeURL.appendingPathComponent("issues")
    }

    private var donateURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://github.com/sponsors/lswank")!
    }

    private var websiteURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://menustow.com")!
    }

    private var lastUpdateCheckString: String {
        if let date = updatesManager.lastUpdateCheckDate {
            date.formatted(date: .abbreviated, time: .standard)
        } else {
            "Never"
        }
    }

    var body: some View {
        if #available(macOS 26.0, *) {
            contentForm(cornerStyle: .continuous)
        } else {
            contentForm(cornerStyle: .circular)
        }
    }

    @ViewBuilder
    private func contentForm(cornerStyle: RoundedCornerStyle) -> some View {
        MenustowForm(spacing: 0) {
            mainContent(containerShape: RoundedRectangle(cornerRadius: 20, style: cornerStyle))
            Spacer(minLength: 10)
            bottomBar(containerShape: Capsule(style: cornerStyle))
        }
        .sheet(isPresented: $showingAcknowledgements) {
            AcknowledgementsSheet()
        }
    }

    @ViewBuilder
    private func mainContent(containerShape: some InsettableShape) -> some View {
        MenustowSection(spacing: 0, options: .plain) {
            appIconAndCopyrightSection
                .layoutPriority(1)

            Spacer(minLength: 0)
                .frame(maxHeight: 20)

            updatesSection
                .layoutPriority(1)
        }
        .padding(.top, 5)
        .padding([.horizontal, .bottom], 30)
        .frame(maxHeight: 500)
        .background(.quinary, in: containerShape)
        .containerShape(containerShape)
    }

    @ViewBuilder
    private var appIconAndCopyrightSection: some View {
        MenustowSection(options: .plain) {
            HStack(spacing: 10) {
                if let nsImage = NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140)
                }

                VStack(alignment: .leading) {
                    Text("menustow")
                        .font(.system(size: 48))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)

                    Text("Menu bar organization for macOS")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)

                    Text("Version \(Constants.versionString) (\(Constants.buildString))")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)

                    Text("Forked from Ice.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary.opacity(0.67))

                    Text("Ice © Jordan Baird. menustow © Lorenzo Swank.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary.opacity(0.67))

                    Text("Why menustow")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)

                    Text(
                        "Jordan fixed bugs and shipped Ice on Homebrew under the @beta tag, "
                        + "then the project went quiet for 6+ months. I was upset I couldn’t "
                        + "just brew install a maintained build, so I picked it up and integrated "
                        + "changes I saw elsewhere. I hope Jordan is healthy and just busy, "
                        + "but here we are."
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary.opacity(0.67))
                }
                .fontWeight(.medium)
            }
        }
    }

    @ViewBuilder
    private var updatesSection: some View {
        MenustowSection(options: .hasDividers) {
            automaticallyCheckForUpdates
            automaticallyDownloadUpdates
            if updatesManager.canCheckForUpdates {
                checkForUpdates
            }
        }
        .frame(maxWidth: 600)
    }

    @ViewBuilder
    private var automaticallyCheckForUpdates: some View {
        Toggle(
            "Automatically check for updates",
            isOn: $updatesManager.automaticallyChecksForUpdates
        )
    }

    @ViewBuilder
    private var automaticallyDownloadUpdates: some View {
        Toggle(
            "Automatically download updates",
            isOn: $updatesManager.automaticallyDownloadsUpdates
        )
    }

    @ViewBuilder
    private var checkForUpdates: some View {
        HStack {
            Button("Check for Updates") {
                updatesManager.checkForUpdates()
            }
            Spacer()
            Text("Last checked: \(lastUpdateCheckString)")
                .font(.caption)
        }
    }

    @ViewBuilder
    private func bottomBar(containerShape: some InsettableShape) -> some View {
        HStack {
            Button("Quit menustow") {
                NSApp.terminate(nil)
            }
            Spacer()
            Button("Acknowledgements") {
                showingAcknowledgements = true
            }
            Button("Website") {
                openURL(websiteURL)
            }
            Button("Contribute") {
                openURL(contributeURL)
            }
            Button("Report a Bug") {
                openURL(issuesURL)
            }
            Button("Support menustow", systemImage: "heart.circle.fill") {
                openURL(donateURL)
            }
        }
        .padding(8)
        .buttonStyle(BottomBarButtonStyle())
        .background(.quinary, in: containerShape)
        .containerShape(containerShape)
        .frame(height: 40)
    }
}

private struct BottomBarButtonStyle: ButtonStyle {
    @State private var isHovering = false

    private var borderShape: some InsettableShape {
        ContainerRelativeShape()
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background {
                borderShape
                    .fill(configuration.isPressed ? .tertiary : .quaternary)
                    .opacity(isHovering ? 1 : 0)
            }
            .contentShape([.focusEffect, .interaction], borderShape)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

private struct AcknowledgementsSheet: View {
    private var acknowledgementsText: AttributedString {
        guard let url = Bundle.main.url(forResource: "Acknowledgements", withExtension: "md"),
              let data = try? Data(contentsOf: url),
              let markdown = String(data: data, encoding: .utf8) else {
            return AttributedString("Acknowledgements could not be loaded.")
        }

        if let attributed = try? AttributedString(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        ) {
            return attributed
        }

        return AttributedString(markdown)
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Acknowledgements")
                .font(.title2.weight(.semibold))
            ScrollView {
                Text(acknowledgementsText)
                    .textSelection(.enabled)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .frame(minWidth: 680, minHeight: 520)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
    }
}
