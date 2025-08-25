import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quartz/models/credential_entry.dart';
import 'package:quartz/providers/credential_providers.dart';
import 'package:quartz/screens/home/credentials/view_credentials_screen.dart';
import 'package:quartz/services/app_services.dart';

class CredentialTile extends ConsumerWidget {
  final CredentialEntry credential;
  final VoidCallback onDelete;
  const CredentialTile({
    super.key,
    required this.credential,
    required this.onDelete,
  });

  IconData _getIconForServiceName(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains("lap") || lowerName.contains("laptop")) {
      return FontAwesomeIcons.laptop;
    }
    if (lowerName.contains("pc") ||
        lowerName.contains("desktop") ||
        lowerName.contains("computer")) {
      return FontAwesomeIcons.desktop;
    }

    if (lowerName.contains('facebook')) return FontAwesomeIcons.facebook;
    if (lowerName.contains('twitter') ||
        lowerName.contains('x.com') ||
        lowerName == 'x') {
      return FontAwesomeIcons.xTwitter;
    }
    if (lowerName.contains('instagram')) return FontAwesomeIcons.instagram;
    if (lowerName.contains('duolingo')) return FontAwesomeIcons.duolingo;
    if (lowerName.contains('linkedin')) return FontAwesomeIcons.linkedin;
    if (lowerName.contains('tiktok')) return FontAwesomeIcons.tiktok;
    if (lowerName.contains('snapchat')) return FontAwesomeIcons.snapchat;
    if (lowerName.contains('pinterest')) return FontAwesomeIcons.pinterest;
    if (lowerName.contains('reddit')) return FontAwesomeIcons.reddit;
    if (lowerName.contains('whatsapp')) return FontAwesomeIcons.whatsapp;
    if (lowerName.contains('telegram')) return FontAwesomeIcons.telegram;
    if (lowerName.contains('discord')) return FontAwesomeIcons.discord;
    if (lowerName.contains('youtube')) return FontAwesomeIcons.youtube;
    if (lowerName.contains('slack')) return FontAwesomeIcons.slack;
    if (lowerName.contains('skype')) return FontAwesomeIcons.skype;
    if (lowerName.contains('zoom')) return FontAwesomeIcons.video;

    if (lowerName.contains('google')) return FontAwesomeIcons.google;
    if (lowerName.contains('apple')) return FontAwesomeIcons.apple;
    if (lowerName.contains('microsoft') ||
        lowerName.contains('windows') ||
        lowerName.contains('outlook') ||
        lowerName.contains('office')) {
      return FontAwesomeIcons.microsoft;
    }
    if (lowerName.contains('github')) return FontAwesomeIcons.github;
    if (lowerName.contains('gitlab')) return FontAwesomeIcons.gitlab;
    if (lowerName.contains('bitbucket')) return FontAwesomeIcons.bitbucket;
    if (lowerName.contains('docker')) return FontAwesomeIcons.docker;
    if (lowerName.contains('stack overflow')) {
      return FontAwesomeIcons.stackOverflow;
    }
    if (lowerName.contains('trello')) return FontAwesomeIcons.trello;
    if (lowerName.contains('jira')) return FontAwesomeIcons.jira;
    if (lowerName.contains('notion')) return FontAwesomeIcons.n;
    if (lowerName.contains('leetcode')) return FontAwesomeIcons.code;

    if (lowerName.contains('aws') ||
        (lowerName.contains('amazon') && lowerName.contains('web'))) {
      return FontAwesomeIcons.aws;
    }
    if (lowerName.contains('google cloud') || lowerName.contains('gcp')) {
      return FontAwesomeIcons.google;
    }
    if (lowerName.contains('digitalocean')) {
      return FontAwesomeIcons.digitalOcean;
    }
    if (lowerName.contains('dropbox')) return FontAwesomeIcons.dropbox;
    if (lowerName.contains('google drive')) return FontAwesomeIcons.googleDrive;

    if (lowerName.contains('amazon')) return FontAwesomeIcons.amazon;
    if (lowerName.contains('ebay')) return FontAwesomeIcons.ebay;
    if (lowerName.contains('paypal')) return FontAwesomeIcons.paypal;
    if (lowerName.contains('stripe')) return FontAwesomeIcons.stripe;
    if (lowerName.contains('shopify')) return FontAwesomeIcons.shopify;
    if (lowerName.contains('visa')) return FontAwesomeIcons.ccVisa;
    if (lowerName.contains('mastercard')) return FontAwesomeIcons.ccMastercard;
    if (lowerName.contains('american express') || lowerName.contains('amex')) {
      return FontAwesomeIcons.ccAmex;
    }

    if (lowerName.contains('spotify')) return FontAwesomeIcons.spotify;
    if (lowerName.contains('netflix')) return Icons.movie_filter;
    if (lowerName.contains('twitch')) return FontAwesomeIcons.twitch;
    if (lowerName.contains('steam')) return FontAwesomeIcons.steam;
    if (lowerName.contains('disney')) return FontAwesomeIcons.film;
    if (lowerName.contains('playstation')) return FontAwesomeIcons.playstation;
    if (lowerName.contains('xbox')) return FontAwesomeIcons.xbox;

    if (lowerName.contains('mail') || lowerName.contains('@')) {
      return Icons.email_outlined;
    }

    if (lowerName.contains('bank')) return Icons.account_balance;
    if (lowerName.contains('shop')) return Icons.shopping_cart_outlined;
    if (lowerName.contains('http') ||
        lowerName.contains('.com') ||
        lowerName.contains('.org') ||
        lowerName.contains('.net')) {
      return Icons.public;
    }
    if (lowerName
        .split(" ")
        .any(
          (bankName) => [
            "fed",
            "federal",
            "sbi",
            "canara",
            "bank",
            "icici",
            "iob",
          ].contains(bankName),
        )) {
      return Icons.account_balance;
    }
    if (lowerName
        .split(" ")
        .any(
          (osName) => [
            "fedora",
            "kali",
            "mint",
            "pop",
            "ubuntu",
            "debian",
          ].contains(lowerName),
        )) {
      return FontAwesomeIcons.linux;
    }

    if (lowerName.contains("lock")) return Icons.lock_outline;
    if (lowerName.contains("nsp") ||
        lowerName.contains("scholar") ||
        lowerName.contains("scholarship")) {
      return Icons.school_sharp;
    }
    if (lowerName
        .split(" ")
        .any(
          (ideName) => [
            "clion",
            "intellij",
            "vs",
            "code",
            "pycharm",
          ].contains(lowerName),
        )) {
      return Icons.code;
    }

    if (["mongodb", "postgres", "oracledb"].contains(lowerName)) {
      return FontAwesomeIcons.database;
    }

    if (lowerName.contains("phone")) return Icons.phone_outlined;

    return Icons.vpn_key_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void _showEditEntry(CredentialEntry currentCredentialEntry) {
      final newValueController = TextEditingController();
      newValueController.text = currentCredentialEntry.serviceName;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Edit ${currentCredentialEntry.serviceName}"),
          content: TextField(
            controller: newValueController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Service Name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final newValue = newValueController.text;

                if (newValue.isEmpty) {
                  return;
                }

                final updatedCredentials = CredentialEntry(
                  id: currentCredentialEntry.id,
                  serviceName: newValue,
                  category: currentCredentialEntry.category,
                  fields: currentCredentialEntry.fields,
                );

                ref
                    .read(credentialBoxProvider)
                    .put(updatedCredentials.id, updatedCredentials);

                showMessage(context, "Service Name updated Succesfully");

                Navigator.of(context).pop();
              },
              child: Text(
                "Save",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: FaIcon(
          _getIconForServiceName(credential.serviceName),
          size: 32,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          credential.serviceName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(credential.fields.first.value),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
                size: 28,
              ),
            ),
            IconButton(
              onPressed: () => _showEditEntry(credential),
              icon: Icon(
                Icons.edit_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
          ],
        ),
        onTap: () => navigatePush(
          context,
          ViewCredentialsScreen(credentialId: credential.id),
        ),
      ),
    );
  }
}
