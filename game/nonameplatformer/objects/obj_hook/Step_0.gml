
var keyLaunch =			mouse_check_button_pressed(mb_left);
var keyRelease =		mouse_check_button_pressed(mb_right);
	
	
if (obj_player.state == playerState.dead) {
	
	canUse = false;
	
} else {
	
	canUse = true;
	
}
	
if (state == hookState.embedded)
	if (ropeDrawTimer <= 0) ropeDrawTimer = 0; else ropeDrawTimer--;
else
	ropeDrawTimer = 4;
	
angleToMouse = point_direction(x, y, global.game.mouseXR, global.game.mouseYR);
			
ray = raycast(x,
			  y,
			  x + lengthdir_x(maxRange + obj_player.hsp, angleToMouse),
			  y + lengthdir_y(maxRange + obj_player.vsp, angleToMouse),
			  par_solid);	
	
if ( (ray[0] != noone) && (ray[0].object_index == obj_attachable_8) ) {
	global.game.cursorType = cursorSprite.hookReady;
} else {
	global.game.cursorType = cursorSprite.hook;
}
	
if (soundTrigger) {
		
	if (soundTimer <= 0) {
				
		soundTimer = soundTimerMax;
		soundTrigger = false;
				
	} else soundTimer--;

}
	
switch (state) {
	
	case hookState.onPlayer:
		
		hsp = 0;
		vsp = 0;
		catchTime = 0;
		launchTime = 0;
		hookPullEnd = false;
		ropeImpulse = 0;
		ropeID = noone;
			
		if ( (keyLaunch) && (canUse) ) {
	
			if (obj_inventory.equipped != weaponEnum.hook) exit;
	
			launchAngle = angleToMouse;
				
			state = hookState.launched;
				
			if (ray[0] != noone) {
					
				if (ray[0].object_index == obj_attachable_8) {
					
					if (ray[0].canBeAttachedTo)
					&& (ray[0].canCollide)
					&& (!ray[0].semiSolid) {
					
						embeddedTo = ray[0];
						anchorX = ray[1];
						anchorY = ray[2];
							
					
					}
					
				}
					
			}
	
		}
			
		hookAngle = angleToMouse;
			
	break;
	case hookState.launched:
		
		if (obj_inventory.equipped != weaponEnum.hook) exit;
		
		launchTime++;
		catchTime = 0;
			
		if (launchTime > launchTimeMax)
		|| (keyRelease) {
			
			state = hookState.released;
			
		}
			
		hookAngle = launchAngle;
			
		hsp = lengthdir_x(launchSpd, launchAngle);
		vsp = lengthdir_y(launchSpd, launchAngle);
			
		if (embeddedTo != noone) {
				
			x = anchorX;
			y = anchorY;
		
			var distance = point_distance(drawX, drawY, anchorX, anchorY);
			var velocity = sqrt(sqr(hsp) + sqr(vsp));
			
			timeToEmbed = distance / velocity;
			
			drawX = lerp(drawX, anchorX, .5);
			drawY = lerp(drawY, anchorY, .5);
			
			if (embedTimer >= timeToEmbed) {
			
				embedTimer = 0;
				timeToEmbed = 0;
				state = hookState.embedded;
			
			} else {
				
				embedTimer++;
				
			}
			
		} else {
			
			drawX += hsp;
			drawY += vsp;
				
			//var _rangeX = (maxRange / 2) * sign(hsp);
			//var _rangeY = (maxRange / 2) * sign(vsp);
				
			var distance = point_distance(x, y, drawX, drawY);
			//var maxDistance = point_distance(x, y, x + maxRange, y + maxRange);
				
			if (distance > maxRange - spdBase)
				state = hookState.released;
		}
	
		if (!soundTrigger) {
			
			audio_play_sound(snd_hook_launch, 1, false);
			soundTrigger = true;
			
		}
		

			
	break;
	case hookState.released:
	
		if (obj_inventory.equipped != weaponEnum.hook) exit;
		
		if (ropeID != noone) {
				
			instance_destroy(ropeID);
			ropeID = noone;
				
		}
		
		ropeImpulse = 0;
		
		launchTime = 0;
		catchTime++;
			
		if (embeddedTo != noone) {
			obj_player.offHookTrigger = true;
			obj_player.hspAtRelease = hsp;
		}
			
		embeddedTo = noone;
		anchorX = -1;
		anchorY = -1;
		
		var returnTo = obj_player;
		//var returnToX = returnTo.x;
		//var returnToY = returnTo.y;
			
		if (collision_circle(drawX, drawY, 12, returnTo, true, false))
		|| (catchTime >= catchTimeMax) {
			
			state = hookState.onPlayer;
			catchTime = 0;
			
		}
			
		hookAngle = point_direction(drawX, drawY, returnTo.x, returnTo.y) + 180;
		drawX = lerp(drawX, returnTo.x, .25);
		drawY = lerp(drawY, returnTo.y, .25);
			
		x = returnTo.x;
		y = returnTo.y;
			
		if (!soundTrigger) {
			
			audio_play_sound(snd_hook_release, 1, false);
			soundTrigger = true;
			
		}
		
	break;
	case hookState.embedded:
	
		if (obj_inventory.equipped != weaponEnum.hook) exit;
		
		if (obj_player.inAir) obj_player.isJumping = true;
		
		if (!ropeImpulse)
			ropeImpulse = 1;
			
		if (ropeImpulse == 1) {
			
			var aX = anchorX;
			var aY = anchorY;
			
			ropeID = instance_create_layer(aX, aY, LAYER_INST, obj_rope_anchor);
				
			with (ropeID) {
				
				anchorX = aX;
				anchorY = aY;
					
			}
				
			audio_play_sound(snd_hook_embed, 1, false);
				
			ropeImpulse = 2;
			
		}
		
		if (embeddedTo != noone) {
				
			x = anchorX;
			y = anchorY;
			drawX = x;
			drawY = y;
			
		}
		
		catchTime = 0;
		launchTime = 0;
		
		if (keyRelease)
			state = hookState.released;
			
		hsp = 0;
		vsp = 0;
		
	break;
		
}
	