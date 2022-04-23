/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CWitcherGame
/** Copyright © 2009
/***********************************************************************/

import class CAIParams extends CObject
{
	import var debugLogSenses : bool;
	import var debugLogBehTree : bool;
	import var debugLogArbitrator : bool;
	import var debugLogCombatArea : bool;
	import var debugHistoryEnabled : bool;
}

import class CWitcherGame extends CGame
{
	import public var hardQte : bool;
	import public var subtitlesEnabled : bool;

	var aiInfoDisplayMode : name;			// Main AI visual debug info mode
	var criticalEffectsManager : W2CriticalEffectsManager;
	var combatEventsManager : W2CombatEventsManager;
	var fistfightManager : W2FistfightManager;	
	var zagnica : Zagnica; // tempshit
	var csTakedown : CSTakedown;
	var dragon : CDragon;
	var targetingAreas : array< W2TargetingArea >;
	var isPlayerOnArena : bool;
	var arenaManager : CArenaManager;
	var cameraFovValue : float;
	var cameraInOutValue : float;
	var cameraLeftRightValue : float;
	var cameraUpDowmValue : float;

	default aiInfoDisplayMode 							= 'all';
	default cameraFovValue = 70.0;
	default cameraInOutValue = 1.0;
	default cameraLeftRightValue = 0.0;
	default cameraUpDowmValue = 5.0;
	
	function SetDragon( drag : CDragon )
	{
		dragon = drag;
	}
	
	// Get AIParams object
	import final function GetAIParams() : CAIParams;
	
	// Get position evaluator
	import final function GetAIPositionEvaluator() : CAIPositionEvaluator;
	
	// Get active HUD
	import final function GetHud() : CHudInstance;

	// Get the game player
	// DEPRECATED: Use thePlayer instead
	//import final function GetPlayer() : CPlayer;
	
	// Get NPC by name (slow, use for debug purposes only)
	import final function GetNPCByName( npcName : string ) : CNewNPC;

	// Get all known NPCs
	import final function GetAllNPCs( out npcs : array<CNewNPC> );
	
	// Get AI blackboard
	import final function GetBlackboard() : CBlackboard;
	
	// Get Action Point Manager
	import final function GetAPManager() : CActionPointManager;
	
	// Set global attitude
	import final function SetGlobalAttitude( srcGroup : name, dstGroup : name, attitude : EAIAttitude );

	// Set global affiliation
	import final function SetGlobalAffiliation( srcGroup : name, dstGroup : name, affiliation : EAIAffiliation );

	// Get Reactions Manager
	import final function GetReactionsMgr() : CReactionsManager;
	
	// Get Story Scene System
	import final function GetStorySceneSystem() : CStorySceneSystem;
	
	// Get Quest Log Manager
	import final function GetQuestLogManager() : CQuestLogManager;
	
	// Start sepia effect
	import final function StartSepiaEffect( fadeInTime: float ) : bool;
	
	// Start sepia effect
	import final function StopSepiaEffect( fadeOutTime: float ) : bool;

	// Get Formations Manager
	import final function GetFormationsMgr() : CFormationsManager;

	// Get node by tag
	import final function GetActorByTag( tag : name ) : CActor;
	import final function GetNPCByTag( tag : name ) : CNewNPC;
	
	// Get nodes by tag
	import final function GetActorsByTag( tag : name, out actors : array<CActor> );
	import final function GetNPCsByTag( tag : name, out npcs : array<CNewNPC> );
	
	// Static AI lights (currently CAreaComponent or derived)
	import final function RegisterStaticAILight( area : CAreaComponent );
	import final function UnregisterStaticAILight( area : CAreaComponent );

	// Animation logging
	import final function StartAnimationLogging();
	import final function StopAnimationLogging();
	
	import final function GetRidOfNPCsFromPlace( center : Vector, rangeX : float, rangeY : float, rangeZ : float, teleportRange : float, npcsToOmit : array< CNewNPC > ) : bool;
	
	import final function GetRidOfNPCsFromArea( area : CAreaComponent, teleportRange : float, npcsToOmit : array< CNewNPC > ) : bool;
	
	import final function GetFirstKeyForGameInput( gameInputName : name ) : string;
	
	import final function GetInputKeyForAction( actionName : string ) : int;
	
	import final function EnableButtonInteractions( enable : bool );
	
	import final function GetGameLanguage( out audioLang : int, out subtitleLang : int );
	import final function GetGameLanguageName( out audioLang : string, out subtitleLang : string );
	
	// Get an array of game input mapping structures
	import final function GetGameInputMappings( mappings : array< SGameInputMapping > );
	
	// Load last game
	import final function LoadLastGame() : bool;
	
	// Apply data imported from W1 save 
	import final function ApplyImportedOldSave();
	
	// Checks if game time manager is paused
	import final function IsGameTimePaused() : bool;
	
	// Is instant qte enabled
	import final function IsQTEHard() : bool;
	
	import final function SyncEntityAnimations( master : CAnimatedComponent, slave : CAnimatedComponent ) : bool;
	
	// Saves the game
	import final function SaveGame( optional ignoreSaveLocks : bool );
	
	//////////////////////
	// Entity state modifiers
	import final function AddStateChangeRequest( entityTag : name, modifier : IEntityStateChangeRequest );
	
	//////////////////////
	// Save locks
	// Creates a new save lock
	import final function CreateNoSaveLock( reason : string, out lock : int );
	
	// Releases an existing save lock
	import final function ReleaseNoSaveLock( lock : int );
	
	// Gets current language in two letters format (e.g. "EN")
	import final function GetCurrentLocale() : string;
	
	///////////////////////////////////////////////////////////////////
	// Config
	
	import final function ReadConfigParamFloat( category, section, key : string, out param : float ) : bool;
	import final function WriteConfigParamFloat( category, section, key : string, param : float ) : bool;
	
	import final function GetGameRelease() : string;
	
	// Camera invert handling
	
	import final function IsInvertCameraX() : bool;
	import final function IsInvertCameraY() : bool;
	import final function SetInvertCameraX( invert : bool );
	import final function SetInvertCameraY( invert : bool );

	// Game starting (no world yet)
	event OnGameStarting()
	{	
		var aiParams : CAIParams;
		aiParams = GetAIParams();
		//aiParams.debugLogArbitrator = true;		
		//aiParams.debugLogSenses = true;
		//aiParams.debugHistoryEnabled = true;
		
		criticalEffectsManager = new W2CriticalEffectsManager in this;
		criticalEffectsManager.Initialize();
		
		combatEventsManager = new W2CombatEventsManager in this;
		combatEventsManager.Initialize();

		csTakedown = new CSTakedown in this;
		csTakedown.Initialize();
		
		targetingAreas.Clear();

		isPlayerOnArena = false;
		arenaManager = NULL;
		
		theHud.OnGameStarting();
	}
	
	// Game started (world is already loaded)
	event OnGameStarted()
	{	
		theHud.OnGameStarted();
		theGame.ResetTutorialData();
		if( thePlayer.GetCurrentMapId() == 1234 )
		{
			theHud.m_map.LoadMapFromEntity();
		}
		else
		{
			theHud.MapLoad( thePlayer.GetCurrentMapId() );
		}
				
		theGame.ReadConfigParamFloat( "User", "Gameplay", "CameraFOV", cameraFovValue );
		theGame.ReadConfigParamFloat( "User", "Gameplay", "CameraLeftRight", cameraLeftRightValue );
		theGame.ReadConfigParamFloat( "User", "Gameplay", "CameraInOut", cameraInOutValue );
		theGame.ReadConfigParamFloat( "User", "Gameplay", "CameraUpDown", cameraUpDowmValue );

		theCamera.SetFov( cameraFovValue );
		theCamera.SetBehaviorVariable('camera_axis_X', cameraLeftRightValue);
		theCamera.SetBehaviorVariable('cameraFurther', cameraInOutValue);
		theCamera.SetBehaviorVariable('camera_axis_Z', cameraUpDowmValue);
	}
	
	// Game ended
	event OnGameEnded()
	{
		criticalEffectsManager = NULL;
		fistfightManager = NULL;
		combatEventsManager = NULL;
		SetTimeScale( 1.0 );
		targetingAreas.Clear();
		theHud.OnGameEnded();
	}
	
	event OnGameInputEvent( key : name, value : float )
	{
		if ( key == 'GI_H' && IsKeyPressed( value ) )
		{
			theHud.SetGuiVisibility( ! theHud.IsGuiVisible() );
				
			theCamera.SetFov( cameraFovValue );
			theCamera.SetBehaviorVariable('camera_axis_X', cameraLeftRightValue);
			theCamera.SetBehaviorVariable('cameraFurther', cameraInOutValue);
			theCamera.SetBehaviorVariable('camera_axis_Z', cameraUpDowmValue);
		}
		else if ( key == 'GI_Camera_Left' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_Left();
			thePlayer.AddTimer('ExperiencedGeralt_Timer_Camera_Left', 0.150, true, false);
		}
		else if ( key == 'GI_Camera_Right' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_Right();
			thePlayer.AddTimer('ExperiencedGeralt_Timer_Camera_Right', 0.150, true, false);
		}
		else if ( key == 'GI_Camera_Up' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_Up();
			thePlayer.AddTimer('ExperiencedGeralt_Timer_Camera_Up', 0.150, true, false);
		}
		else if ( key == 'GI_Camera_Down' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_Down();
			thePlayer.AddTimer('ExperiencedGeralt_Timer_Camera_Down', 0.150, true, false);
		}
		else if ( key == 'GI_Camera_In' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_In();
			thePlayer.AddTimer('ExperiencedGeralt_Timer_Camera_In', 0.150, true, false);
		}
		else if ( key == 'GI_Camera_Out' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_Out();
			thePlayer.AddTimer('ExperiencedGeralt_Timer_Camera_Out', 0.150, true, false);
		}
		else if ( key == 'GI_Camera_Reset' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_Reset();
		}
		else if ( key == 'GI_Camera_ReverseSide' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_ReverseSide();
		}
		else if ( key == 'GI_Camera_FOV_Decrease' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_FOV_Decrease();
			thePlayer.AddTimer('ExperiencedGeralt_Timer_Camera_FOV_Decrease', 0.150, true, false);
		}
		else if ( key == 'GI_Camera_FOV_Increase' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_FOV_Increase();
			thePlayer.AddTimer('ExperiencedGeralt_Timer_Camera_FOV_Increase', 0.150, true, false);
		}
		else if ( key == 'GI_Camera_FOV_Reset' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_FOV_Reset();
		}
		else if ( key == 'GI_Camera_FirstPersonTemplate' && IsKeyPressed( value ) )
		{
			ExperiencedGeralt_Camera_FirstPersonTemplate();
		}
		
		return false;
	}
	
	event OnGameInputDoubleTap( key : name, value : float )
	{
	}
	
	event OnRainStarted()
	{	
	    var nodes : array <CNode>;
	    var light : CLocationLights;
	    var i : int;
		if ( thePlayer.GetCurrentPlayerState() == PS_Exploration ) theHud.m_hud.ShowTutorial("tut31", "", false); // Rain tutorial
		//if ( thePlayer.GetCurrentPlayerState() == PS_Exploration ) theHud.ShowTutorialPanelOld( "tut31", "" ); // Rain tutorial
		theGame.GetNodesByTag('city_light', nodes );
		for( i=0; i < nodes.Size(); i+=1 )
		{
			light = (CLocationLights) nodes[i];
			if ( light ) light.OnRainStarted();
		}
	}
	
	event OnRainEnded()
	{	
	    var nodes : array <CNode>;
	    var light : CLocationLights;
	    var i : int;
		theGame.GetNodesByTag('city_light', nodes );
		for( i=0; i < nodes.Size(); i+=1 )
		{
			light = (CLocationLights) nodes[i];
			if ( light ) light.OnRainEnded();
		}
	}
		
	final function GetCriticalEffectsMgr() : W2CriticalEffectsManager { return criticalEffectsManager; }
	
	final function GetCombatEventsManager() : W2CombatEventsManager { return combatEventsManager; }
	
	
	/*final function GetBalanceCalc() : W2BalanceCalc
	{
		
	}*/
	
	final function GetFistfightManager() : W2FistfightManager
	{
		if( !fistfightManager )
		{
			fistfightManager = new W2FistfightManager in this;
			fistfightManager.Idle();
		}
		
		return fistfightManager;
	}

	final function GetFistfightManagerWithoutCreation() : W2FistfightManager
	{
		return fistfightManager;
	}	
		
	final latent function GetNPCByTagWithTimeout( tag : name, timeout : float ) : CNewNPC
	{
		var npc : CNewNPC;
		npc = GetNPCByTag( tag );
		
		while ( ! npc && timeout > 0.f )
		{
			npc = GetNPCByTag( tag );
			
			Sleep ( 0.5f );
			timeout -= 0.5f;
		}
		
		return npc;
	}
	
	final latent function GetActorByTagWithTimeout( tag : name, timeout : float ) : CActor
	{
		var actor : CActor;
		actor= GetActorByTag( tag );
		
		while ( ! actor && timeout > 0.f )
		{
			actor = GetActorByTag( tag );
			
			Sleep ( 0.5f );
			timeout -= 0.5f;
		}
		
		return actor;
	}
	
	final latent function GetNodeByTagWithTimeout( tag : name, timeout : float ) : CNode
	{
		var node : CNode;
		node = GetNodeByTag( tag );
		
		while ( ! node && timeout > 0.f )
		{
			node = GetNodeByTag( tag );
			
			Sleep ( 0.5f );
			timeout -= 0.5f;
		}
		
		return node;
	}
	
	function GetCSTakedown() : CSTakedown
	{
		return csTakedown;
	}

	function RegisterTargetingArea( area : W2TargetingArea )
	{
		if( !targetingAreas.Contains( area ) )
		{
			targetingAreas.PushBack( area );
		}
	}
	final function SetPlayerOnArena(flag : bool, arena : CArenaManager)
	{
		isPlayerOnArena = flag;
		arenaManager = arena;
	}
	final function GetIsPlayerOnArena() : bool
	{
		var arena : CArenaManager;
		arena = (CArenaManager)theGame.GetNodeByTag('arena_manager');
		if(arena)
		{
			return isPlayerOnArena;
		}
		else
		{
			return false;
		}
	}
	final function GetArenaManager() : CArenaManager
	{
		return arenaManager;
	}
	function UnregisterTargetingArea( area : W2TargetingArea )
	{
		targetingAreas.Remove( area );
	}
	
	function TargetingAreasPresent() : bool
	{
		return targetingAreas.Size() > 0;
	}
	
	function TargetingAreasTest( entity : CEntity ) : bool
	{
		var i : int;
		var res : W2TargetingTestResult;
		for( i=targetingAreas.Size()-1; i>=0; i-=1 )
		{
			if( targetingAreas[i] )
			{
				res = targetingAreas[i].TargetingTest( entity );
				if( res == TTR_PlayerInsideTargetInside )
				{
					return true;
				}
				else if( res == TTR_PlayerInsideTargetOutside )
				{
					return false;
				}
			}
		}
		
		return true;
	}
	function GetIsNight() : bool
	{
		var currentHour : int;
		var gameTime : GameTime;
		gameTime = theGame.GetGameTime();
		currentHour = GameTimeHours(gameTime);
		if(currentHour <= 24 && currentHour >= 21)
			return true;
		if(currentHour >= 0 && currentHour <= 5)
			return true;
		return false;
	}
	function GetIsDay() : bool
	{
		var currentHour : int;
		var gameTime : GameTime;
		gameTime = theGame.GetGameTime();
		currentHour = GameTimeHours(gameTime);
		if(currentHour <= 24 && currentHour > 21)
			return false;
		if(currentHour >= 0 && currentHour < 5)
			return false;
		return true;
	}
	
	event OnCannotQuickloadInsane()
	{
		var message : CGuiCannotLoadSave;
		
		message = new CGuiCannotLoadSave in theHud.m_messages;
		message.exitAfterOk = !thePlayer.IsAlive();
		theHud.m_messages.ShowConfirmationBox( message );
	}
};

// Use 'theGame' global variable
//import function GetGame() : CWitcherGame;
import function SendArenaScoreToSteamLeaderboards( score : int, wave : int );

//////////////////////////////////////////////////////////////////////////////////////////
// ExperiencedGeralt Functions Begin
//////////////////////////////////////////////////////////////////////////////////////////

	function ExperiencedGeralt_Camera_Left()
	{
		var CameraPosition : Float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		CameraPosition = theCamera.GetBehaviorVariable('camera_axis_X');
		if ( theGame.GetGameInputValue('GI_WalkSwitch') > 0.5f ) // Walking(Hold) Key
			CameraPosition += 0.20;
		else if ( theGame.GetGameInputValue('GI_ADIST_Medium') > 0.5f ) // Medium Distance Key
			CameraPosition = 0.35;
		else
			CameraPosition += 0.05;
		theCamera.SetBehaviorVariable('camera_axis_X', CameraPosition);
	}
	function ExperiencedGeralt_Camera_Right()
	{
		var CameraPosition : Float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		CameraPosition = theCamera.GetBehaviorVariable('camera_axis_X');
		if ( theGame.GetGameInputValue('GI_WalkSwitch') > 0.5f ) // Walking(Hold) Key
			CameraPosition -= 0.20;
		else if ( theGame.GetGameInputValue('GI_ADIST_Medium') > 0.5f ) // Medium Distance Key
			CameraPosition = -0.35;
		else
			CameraPosition -= 0.05;
		theCamera.SetBehaviorVariable('camera_axis_X', CameraPosition);
	}
	function ExperiencedGeralt_Camera_Up()
	{
		var CameraPosition : Float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		CameraPosition = theCamera.GetBehaviorVariable('camera_axis_Z');
		CameraPosition -= 0.05;
		theCamera.SetBehaviorVariable('camera_axis_Z', CameraPosition);
	}
	function ExperiencedGeralt_Camera_Down()
	{
		var CameraPosition : Float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		CameraPosition = theCamera.GetBehaviorVariable('camera_axis_Z');
		CameraPosition += 0.05;
		theCamera.SetBehaviorVariable('camera_axis_Z', CameraPosition);
	}
	function ExperiencedGeralt_Camera_In()
	{
		var CameraPosition : Float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		CameraPosition = theCamera.GetBehaviorVariable('cameraFurther');
		if ( theGame.GetGameInputValue('GI_WalkSwitch') > 0.5f ) // Walking(Hold) Key
			CameraPosition -= 0.05;
		else if ( theGame.GetGameInputValue('GI_ADIST_Medium') > 0.5f ) // Medium Distance Key
			CameraPosition = 0.00;
		else
			CameraPosition -= 0.20;
		theCamera.SetBehaviorVariable('cameraFurther', CameraPosition);
	}
	function ExperiencedGeralt_Camera_Out()
	{
		var CameraPosition : Float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		CameraPosition = theCamera.GetBehaviorVariable('cameraFurther');
		if ( theGame.GetGameInputValue('GI_WalkSwitch') > 0.5f ) // Walking(Hold) Key
			CameraPosition += 0.05;
		else if ( theGame.GetGameInputValue('GI_ADIST_Medium') > 0.5f ) // Medium Distance Key
			CameraPosition = 3.00;
		else
			CameraPosition += 0.20;
		theCamera.SetBehaviorVariable('cameraFurther', CameraPosition);
	}
	function ExperiencedGeralt_Camera_Reset()
	{
		var CameraPosition : Float;
		var value : float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		if ( theGame.GetGameInputValue('GI_WalkSwitch') > 0.5f ) // Walking(Hold) Key
		{
			CameraPosition = 0.0;
			theCamera.SetBehaviorVariable('cameraFurther', CameraPosition);
			theCamera.SetBehaviorVariable('camera_axis_X', CameraPosition);
			theCamera.SetBehaviorVariable('camera_axis_Z', CameraPosition);
		}
		else if ( theGame.GetGameInputValue('GI_ADIST_Medium') > 0.5f ) // Medium Distance Key
		{
			value = theCamera.GetFov();
			theGame.WriteConfigParamFloat( "User", "Gameplay", "CameraFOV", value );

			value = theCamera.GetBehaviorVariable('camera_axis_X');
			theGame.WriteConfigParamFloat( "User", "Gameplay", "CameraLeftRight", value );

			value = theCamera.GetBehaviorVariable('cameraFurther');
			theGame.WriteConfigParamFloat( "User", "Gameplay", "CameraInOut", value );

			value = theCamera.GetBehaviorVariable('camera_axis_Z');
			theGame.WriteConfigParamFloat( "User", "Gameplay", "CameraUpDown", value );

			theHud.m_messages.ShowInformationText("General Camera options have been saved to the Ini");
		}
		else
		{
			if ( theGame.ReadConfigParamFloat( "User", "Gameplay", "CameraFOV", value ) )
				theCamera.SetFov( value );

			if ( theGame.ReadConfigParamFloat( "User", "Gameplay", "CameraLeftRight", value ) )
				theCamera.SetBehaviorVariable('camera_axis_X', value);
			else
				theCamera.SetBehaviorVariable('camera_axis_X', CameraPosition);

			if ( theGame.ReadConfigParamFloat( "User", "Gameplay", "CameraInOut", value ) )
				theCamera.SetBehaviorVariable('cameraFurther', value);
			else
				theCamera.SetBehaviorVariable('cameraFurther', CameraPosition);

			if ( theGame.ReadConfigParamFloat( "User", "Gameplay", "CameraUpDown", value ) )
				theCamera.SetBehaviorVariable('camera_axis_Z', value);
			else
				theCamera.SetBehaviorVariable('camera_axis_Z', CameraPosition);
		}
	}
	function ExperiencedGeralt_Camera_ReverseSide()
	{
		var CameraPosition : Float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		CameraPosition = theCamera.GetBehaviorVariable('camera_axis_X');
		CameraPosition *= -1.0;
		theCamera.SetBehaviorVariable('camera_axis_X', CameraPosition);
	}
	function ExperiencedGeralt_Camera_FOV_Decrease()
	{
		var CameraFOV : Float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		CameraFOV = theCamera.GetFov();
		CameraFOV -= 1.0;
		theCamera.SetFov( CameraFOV );
	}
	function ExperiencedGeralt_Camera_FOV_Increase()
	{
		var CameraFOV : Float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		CameraFOV = theCamera.GetFov();
		CameraFOV += 1.0;
		theCamera.SetFov( CameraFOV );
	}
	function ExperiencedGeralt_Camera_FOV_Reset()
	{
		var CameraFOV : Float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		CameraFOV = 53.0;
		theCamera.SetFov( CameraFOV );
	}
	function ExperiencedGeralt_Camera_FirstPersonTemplate()
	{
		var CameraFOV : Float;
		var X,Y,Z : Float;
		var value : float;

		if ( theGame.IsBlackscreen()
		  || theGame.IsCurrentlyPlayingNonGameplayScene()
		  || !theHud.CanShowMainMenu() )
			return;

		X = 0.1;
		Y = -3.0;
		Z = -0.1;
		CameraFOV = 70.0;

		if ( theGame.GetGameInputValue('GI_ADIST_Medium') > 0.5f ) // Medium Distance Key
		{
			value = theCamera.GetFov();
			theGame.WriteConfigParamFloat( "User", "Gameplay", "FirstPerson_CameraFOV", value );

			value = theCamera.GetBehaviorVariable('camera_axis_X');
			theGame.WriteConfigParamFloat( "User", "Gameplay", "FirstPerson_CameraLeftRight", value );

			value = theCamera.GetBehaviorVariable('cameraFurther');
			theGame.WriteConfigParamFloat( "User", "Gameplay", "FirstPerson_CameraInOut", value );

			value = theCamera.GetBehaviorVariable('camera_axis_Z');
			theGame.WriteConfigParamFloat( "User", "Gameplay", "FirstPerson_CameraUpDown", value );

			theHud.m_messages.ShowInformationText("First Person Camera options have been saved to the Ini");
		}
		else
		{
			if ( theGame.ReadConfigParamFloat( "User", "Gameplay", "FirstPerson_CameraFOV", value ) )
				theCamera.SetFov( value );
			else
				theCamera.SetFov( CameraFOV );

			if ( theGame.ReadConfigParamFloat( "User", "Gameplay", "FirstPerson_CameraLeftRight", value ) )
				theCamera.SetBehaviorVariable('camera_axis_X', value);
			else
				theCamera.SetBehaviorVariable('camera_axis_X', X);

			if ( theGame.ReadConfigParamFloat( "User", "Gameplay", "FirstPerson_CameraInOut", value ) )
				theCamera.SetBehaviorVariable('cameraFurther', value);
			else
				theCamera.SetBehaviorVariable('cameraFurther', Y);

			if ( theGame.ReadConfigParamFloat( "User", "Gameplay", "FirstPerson_CameraUpDown", value ) )
				theCamera.SetBehaviorVariable('camera_axis_Z', value);
			else
				theCamera.SetBehaviorVariable('camera_axis_Z', Z);
		}
	}

//////////////////////////////////////////////////////////////////////////////////////////
// ExperiencedGeralt Functions End
//////////////////////////////////////////////////////////////////////////////////////////