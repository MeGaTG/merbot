local function musiclink(msg, musicid)
 local value = redis:hget('music:'..msg.to.peer_id, musicid)
 if not value then
  return
 else
  value = value
    send_api_msg(msg, get_receiver_api(msg), value, true, 'md')
 end
end
function sectomin (Sec)
if (tonumber(Sec) == nil) or (tonumber(Sec) == 0) then
return "00:00"
else
Seconds = math.floor(tonumber(Sec))
if Seconds < 1 then Seconds = 1 end
Minutes = math.floor(Seconds / 60)
Seconds = math.floor(Seconds - (Minutes * 60))
if Seconds < 10 then
Seconds = "0"..Seconds
end
if Minutes < 10 then
Minutes = "0"..Minutes
end
return Minutes..':'..Seconds
end
end

function run(msg, matches)
 if string.match(msg.text, '[\216-\219][\128-\191]') then
  return send_large_msg(get_receiver(msg), 'Please use the English language. ')
 end
 if matches[1]:lower() == "dl" then
  local value = redis:hget('music:'..msg.to.peer_id, matches[2])
  if not value then
   return 'Music not found.'
  else
   value = value
    send_api_msg(msg, get_receiver_api(msg), value, true, 'md')
  end
  return
 end
 
 local url = http.request("http://api.gpmod.ir/music.search/?q="..URL.escape(matches[2]).."&count=30&sort=2")
 
 local jdat = json:decode(url)
 local text , time , num = ''
 local hash = 'music:'..msg.to.peer_id
 redis:del(hash)
 if #jdat.response < 2 then return "No result found." end
  for i = 2, #jdat.response do
   if 900 > jdat.response[i].duration then
   num = i - 1
   time = sectomin(jdat.response[i].duration)
   text = text..num..'- Artist: '.. jdat.response[i].artist .. ' | '..time..'\nTitle: '..jdat.response[i].title..'\n\n'
   redis:hset(hash, num, 'Artist: '.. jdat.response[i].artist .. '\nTitle: '..jdat.response[i].title..' | '..time..'\n\n'.."[Download](http://GPMod.ir/dl.php?q="..jdat.response[i].owner_id.."_"..jdat.response[i].aid..')')
   end
  end
  text = text..'\n----------------------\n*Use the following command to download*.\n\n`!dl <number>`\n\n*(example)*: `!dl 1`\n\n*LionTeam*'
    send_api_msg(msg, get_receiver_api(msg), text, true, 'md')
 end

return {
usage = {'<code>!music [name]</code>\nmusic finder'},
patterns = {
 "^[#!/]([Mm][Uu][Ss][Ii][Cc]) (.*)$",
 "^[#!/]([dD][Ll]) (.*)$"
 }, 
 run = run 
}
