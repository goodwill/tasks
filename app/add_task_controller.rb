class UITextFieldBinding < NSObject
  def initialize(model, ui_field, field_name)
    @model=model
    @field_name=field_name
    self.ui_field=ui_field
  end

  def ui_field=(val)
    @ui_field=val
    @ui_field.delegate=self
    @ui_field.text=@model.send(@field_name)
  end

  def model=(val)
    @model=val
    @ui_field.text=@model.send(@field_name)
  end

  def update(ui_field, model)
    self.ui_field=ui_field
    self.model=model

  end


  def textFieldDidEndEditing(textField)
    @model.send("#{@field_name}=", textField.text)
  end


end


class AddTaskController < UIViewController
  Fields=[{name: :name, label: 'Name', type: :text}, {name: :due_date, label: 'Due Date', type: :date}]
  attr_accessor :mode

  def viewDidLoad
    super

    @table=UITableView.alloc.initWithFrame(self.view.bounds, style: UITableViewStyleGrouped)
    @table.dataSource=self
    @table.delegate=self

    view.addSubview(@table)


    @date_picker=UIDatePicker.alloc.initWithFrame([[0,self.view.bounds.size.height], [0,0]])
    @date_picker.datePickerMode=UIDatePickerModeDate
    @date_picker.addTarget(self, action: 'dateChanged:', forControlEvents: UIControlEventValueChanged)
    view.addSubview(@date_picker)


  end

  def setup(mode, task)
    @saved=FALSE
    @mode=mode
    @task=task

  end
  def viewWillDisappear(animated)
    toggleDatePicker() if @is_date_picker_visible
    @task.MR_deleteEntity if self.mode=='new' && !@saved
    @task.autorelease
    # discard object if new not saved


    super

  end

  def viewWillAppear(animated)
    super
    self.title= self.mode == 'new' ? "Add Task" : "Edit Task"
    @table.reloadData()

  end

  def dateChanged(sender)
    @task.send("#{@selected_field_set[:name]}=", sender.date)
    rowIndex = Fields.index(@selected_field_set)

    @table.reloadRowsAtIndexPaths([NSIndexPath.indexPathForRow(rowIndex, inSection: 0)],
                                  withRowAnimation: UITableViewRowAnimationNone
    )

  end

  def task=(task)
    @task=task
  end

  def task
    return @task
  end


  def tableView(tableView, cellForRowAtIndexPath: index_path)
    field_set = Fields[index_path.row]
    cell_identifier = "CELL_IDENTIFIER_#{field_set[:type].to_s}"
    cell=tableView.dequeueReusableCellWithIdentifier(cell_identifier)
    isReusedCell=!cell.nil?

    cell=UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue2, reuseIdentifier: cell_identifier) unless isReusedCell

    ui_field=create_or_update_field(field_set, cell)

    cell

  end

  def tableView(tableView, didSelectRowAtIndexPath:index_path)
    @selected_field_set=Fields[index_path.row]

    if @selected_field_set[:type]==:date
      self.view.endEditing(true)
      value=@task.send(@selected_field_set[:name])
      @date_picker.date=value unless value.nil?
    end
    toggleDatePicker()

  end

  def toggleDatePicker
    animate_appear=lambda { @date_picker.frame=[[0,self.view.bounds.size.height],[0,0]] }
    animate_disappear=lambda { @date_picker.frame=[[0, self.view.bounds.size.height-@date_picker.bounds.size.height], [0, 0]] }
    if @is_date_picker_visible
      UIView.animateWithDuration(0.3, animations: animate_appear)
      @is_date_picker_visible=false
    else
      UIView.animateWithDuration(0.3, animations: animate_disappear)
      @is_date_picker_visible=true
    end

  end


  def create_or_update_field(field_set, cell)
    ui_field=nil
    bounds=get_detail_view_bounds(cell)
    ap field_set

    cell.textLabel.text=field_set[:label]

    case field_set[:type]
      when :text
        ui_field=cell.contentView.viewWithTag(99)
        if ui_field.nil?
          ui_field=UITextField.alloc.initWithFrame(bounds)
          cell.selectionStyle=UITableViewCellSelectionStyleNone
          ui_field.tag=99
          @bindings[field_set[:name]]=UITextFieldBinding.new(@task, ui_field, field_set[:name])
          cell.contentView.addSubview(ui_field)
        else
          binding=@bindings[field_set[:name]]
          binding.update(ui_field, @task)

        end
      when :date
        value=@task.send(field_set[:name])
        cell.detailTextLabel.text=value.nil? ? "" : value.string_with_style

    end

    ui_field
  end

  def get_detail_view_bounds(cell)
    [[85, 10], [cell.contentView.bounds.size.width - 120, cell.contentView.bounds.size.height - 20]]
  end

  def tableView(tableView, numberOfRowsInSection: section)
    Fields.length
  end

  def saveTask

    self.view.endEditing(true)

    saveHook= lambda do |local_context|
          local_context.save
        end

    MagicalRecord.saveUsingCurrentThreadContextWithBlockAndWait(saveHook)

    @saved=true

    self.navigationController.popViewControllerAnimated(true)

  end

  def initWithNibName(name, bundle: bundle)
    super
    saveTaskButton= UIBarButtonItem.alloc.initWithTitle("Save", style: UIBarButtonSystemItemSave, target: self, action: 'saveTask')
    self.navigationItem.rightBarButtonItem=saveTaskButton
    @bindings={}
    self
  end


end