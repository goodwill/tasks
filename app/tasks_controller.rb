class TasksController < UIViewController
  def viewDidLoad
    super

    @tasks=Task.MR_findAll

    @table = UITableView.alloc.init

    @table.dataSource=self
    @table.delegate=self
    view.addSubview(@table)
  end

  def viewWillAppear(animated)
    super
    @table.frame=view.bounds
    @tasks=Task.MR_findAll
    @table.reloadData()

  end

  def tableView(tableView, cellForRowAtIndexPath: index_path)
    @reuseIdentifier="CELL_IDENTIFIER"

    cell= tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
    end

    cell.textLabel.text = @tasks[index_path.row].name
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    cell

  end

  def tableView(tableView, numberOfRowsInSection: section)
    @tasks.count
  end

  def tableView(tableView, didSelectRowAtIndexPath:index_path)
    @add_task_controller||=AddTaskController.alloc.initWithNibName(nil, bundle: nil)
    @add_task_controller.setup("edit", @tasks[index_path.row])
    self.navigationController.pushViewController(@add_task_controller, animated: true)
  end



  def addTask
    @add_task_controller||=AddTaskController.alloc.initWithNibName(nil, bundle: nil)
    @add_task_controller.setup('new', Task.MR_createEntity)
    self.navigationController.pushViewController(@add_task_controller, animated: true)

  end


  def initWithNibName(name, bundle: bundle)
    super
    self.title="Tasks"
    addTaskButton= UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target: self, action: 'addTask' )
    # UIBarButtonItem.alloc.initWithTitle("+", style: UIBarButtonItemStyleBordered, target: self, action: 'addTask')
    self.navigationItem.rightBarButtonItem=addTaskButton
    self
  end
end