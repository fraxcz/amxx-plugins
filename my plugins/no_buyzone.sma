    #include <amxmodx>
    #include <engine>

    public plugin_precache() 
    { 
        new Entity = create_entity( "info_map_parameters" );
        
        DispatchKeyValue( Entity, "buying", "3" );
        DispatchSpawn( Entity );
    } 
    
    public plugin_init()
    {
        register_plugin( "Remove Buy Zone", "1.0.0", "Arkshine" );
    }

    public pfn_keyvalue( Entity )  
    { 
        new ClassName[ 20 ], Dummy[ 2 ];
        copy_keyvalue( ClassName, charsmax( ClassName ), Dummy, charsmax( Dummy ), Dummy, charsmax( Dummy ) );
        
        if( equal( ClassName, "info_map_parameters" ) ) 
        { 
            remove_entity( Entity );
            return PLUGIN_HANDLED ;
        } 
        
        return PLUGIN_CONTINUE;
    }