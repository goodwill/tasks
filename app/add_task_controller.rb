class UIBoundTextField < UITextField
  attr_reader :field_name

  def initWithFrameAndFieldName(bounds, fieldName: fieldName)
    self.initWithFrame(bounds)
    @field_name=fieldName
    self

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
    @date_picker.addTarget(self, action: 'dateChanged:', forControlEvents: UIControlEventValueChanged)
    view.addSubview(@date_picker)


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

  def textFieldDidEndEditing(textField)
    @task.send("#{textField.field_name}=", textField.text)
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
      UIView.animateWithDuration(0.3,
                                 animations: lambda {
                                   @date_picker.frame=[[0,self.view.bounds.size.height-@date_picker.bounds.size.height],[0,0]]
                                 }
      )
    else
      UIView.animateWithDuration(0.3,
                                 animations: lambda {
                                   @date_picker.frame=[[0,self.view.bounds.size.height],[0,0]]
                                 }
      )

    end

  end


  def create_or_update_field(field_set, cell)
    ui_field=nil
    bounds=get_detail_view_bounds(cell)

    cell.textLabel.text=field_set[:label]

    if field_set[:type]==:text
      ui_field=cell.contentView.viewWithTag(99)
      if ui_field.nil?
        ui_field=UIBoundTextField.alloc.initWithFrameAndFieldName(bounds, fieldName: field_set[:name])
        cell.selectionStyle=UITableViewCellSelectionStyleNone
        ui_field.delegate=self
        ui_field.tag=99
        cell.contentView.addSubview(ui_field)
      end
      ui_field.text=@task.send(field_set[:name])
    elsif field_set[:type]==:date
      value=@task.send(field_set[:name])
      cell.detailTextLabel.text=value.string_with_style unless value.nil?
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

    MagicalRecord.saveUsingCurrentThreadContextWithBlockAndWait(lambda do |local_context|
      local_context.save
    end)

    self.navigationController.popViewControllerAnimated(true)

  end

  def initWithNibName(name, bundle: bundle)
    super
    self.mode ||='new'
    self.title= self.mode == 'new' ? "Add Task" : "Edit Task"
    saveTaskButton= UIBarButtonItem.alloc.initWithTitle("Save", style: UIBarButtonSystemItemSave, target: self, action: 'saveTask')
    self.navigationItem.rightBarButtonItem=saveTaskButton
    self
  end


end