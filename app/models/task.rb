class Task < MotionMigrate::Model
  property :name, :string
  property :due_date, :date

  def inspect
    {name: self.name, due_date: self.due_date}
  end

end