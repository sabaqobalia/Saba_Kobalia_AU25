class Trainee:
    def __init__(self, name, last_name):
        self.name = name
        self.last_name = last_name
        self.visited_lectures = 0
        self.done_home_tasks = 0
        self.missed_lectures = 0
        self.missed_home_tasks = 0
        self.mark = 0

    def _add_points(self, points):
        self.mark = min(10, self.mark + points)

    def _subtract_points(self, points):
        self.mark = max(0, self.mark - points)

    def visit_lecture(self):
        self.visited_lectures += 1
        self._add_points(1)

    def do_homework(self):
        self.done_home_tasks += 2
        self._add_points(2)

    def miss_lecture(self):
        self.missed_lectures -= 1
        self._subtract_points(1)

    def miss_homework(self):
        self.missed_home_tasks -= 2
        self._subtract_points(2)

    def is_passed(self):
        if self.mark >= 8:
            print("Good job!")
        else:
            print(
                f"You need to get {8 - self.mark} more points. Try to do your best!"
            )
