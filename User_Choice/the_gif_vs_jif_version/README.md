# User_Choice_gif_vs_jif_remix

Obviously the 'gif' vs 'jif' battle will rage on until the end of time. If you want to punish your users who say it the wrong way then you can use this to have some fun with that. (If you're one of those people who are objectively wrong, I suppose you could modify these scripts to reflect your improper pronunciation.)

Here, the first script - the Self Service script - writes to one extension attribute which indicates the user pronounces the file extension as 'jif' (if they pronounce it 'gif', then it basically congratulates them and exits). Next, the follow-up script creates the macOS text expansion and gives them one last chance to change their answer. If they switch back to "gif", it corrects the value in the first extension attribute and allows them to delete the text shortcut. If they maintain it's pronounced "jif", the script then writes to a second extension attribute which determines smart group membership and puts the device in scope of a configuration profile that restricts the Keyboard panel within System Preferences. This forces them to live with their error forever or until they re-run the questionaire and fix their answer.

(If you really wanted to force the concept, package up TextExpander with the 'gif' -> 'jif' replacement snippet already created.)

Of course, the main User Choice example is more real world appropriate. This second set of scripts was simply included for fun as a way to demonstrate the versatility of the conceptual backbone of the script. Testing done here was minimal at best and the scripts do take their sweet time but it should still get the point across for humor's sake.
