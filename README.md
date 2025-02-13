# Notion-Bash-Backup
A simple Bash script to automatically download your Notion workspace/content.

**This is an updated and slightly improved version of the original script by [gidoBOSSftw5731](https://github.com/gidoBOSSftw5731/notion-auto-pull).** 💕

---

_Following is the original README.md:_

# notion-auto-pull
Bash script to automatically download a notion workspace



## In case of fire, pull lever
I made this to make sure that if notion goes under ever, I have a backup of all my historical notes in a standard (csv and md are standard, right?) format. I run this hourly on my NAS, but can easily be modified for other uses.

To use this script, just add your cookie and  space ID to the top export lines (see https://medium.com/@arturburtsev/automated-notion-backups-f6af4edc298d for details) and set in cron or simillar to run. It will only output text apon an error (and *should* exit if it does error), so it is intended to send an email if anything changes.

I have ***NOT*** tested this long term, I literally made this in the bash shell and the synology task scheduler UI over the last ~2 hours. Feel free to submit PRs, but I make no promises with issues. I have not added automatic removal or deduplication, so either handle this at the filesystem level or add it here yourself and submit a pr

UPDATE: As of 2021-04-20 I am still getting valid downloads, though sometimes there is a timeout. I could change the timeout to be shorter but I run the backups often enough it's not a concern for me. If you have an issue you can try to debug the code by running it manually if you have the skills/knowhow.

## Inspiration:
A lot of inspiration from the following places
*	This gitlab: https://gitlab.com/aburtsev/notion-backup-script/-/raw/master/.gitlab-ci.yml
	*	Which I found from this article: https://medium.com/@arturburtsev/automated-notion-backups-f6af4edc298d
	*	Which was made by [@artjock](https://github.com/artjock)
*	Was inspired to use the API from: https://www.reddit.com/r/Notion/comments/9jo4kp/how_create_automated_backups_of_entire_notion/
