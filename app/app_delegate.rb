class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    if RUBYMOTION_ENV == 'test'
      MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStoreNamed("TaskDbSpec.sqlite")
    else
      MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStoreNamed("TaskDbPrd.sqlite")
    end

    @window=UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.makeKeyAndVisible

    @tasks_controller=TasksController.alloc.initWithNibName(nil, bundle: nil)
    @nav_controller=UINavigationController.alloc.initWithRootViewController(@tasks_controller)

    @window.rootViewController=@nav_controller
    
    true

  end

  def applicationWillTerminate(application)
    MagicalRecord.cleanUp()
  end
end
