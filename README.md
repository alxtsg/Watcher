# Watcher #

## Description ##

A small script for retrieving system information and optionally sending the
information via e-mail. Written for use on OpenBSD.

## Requirements ##

* curl `(>=7.59.0)`
* Mailgun account (for sending e-mail) (free plan is sufficient).

## Installation ##

0. Download the script.
1. Install dependencies.
2. Update configurations in `watcher.config`.

## Usage ##

There are a number of configurations should be updated before using:

* `enableMail`: Whether the retrieved system information should be sent via
e-mail. Set to `yes` to enable and `no` to disable.
* `domainName`: The active domain on your Mailgun account for sending e-mail.
* `senderName`: The name of sender who the e-mail will be sent on behalf.
* `senderEmail`: The e-mail address of sender who the e-mail will be sent on
behalf.
* `receiverEmail`: The e-mail address that the e-mail will be sent to.

Before configuring Watcher to send e-mail, follow the instructions on Mailgun
to setup the domain properly.

There are 2 log files:

* `logs/mail.log`: The log entries returned from Mailgun.
* `logs/system.log`: The system information retrieved last time.

A cron job can be setup to run the script periodically. For example, add a cron
job by `crontab -e`:

    # Run the script located at /path/to/watcher.sh every 3 hours.
    0 */3 * * * /path/to/watcher.sh

## License ##

[The 3-Clause BSD License](http://opensource.org/licenses/BSD-3-Clause)