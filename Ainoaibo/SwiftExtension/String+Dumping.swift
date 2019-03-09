
extension String {
    public init<T>(dumping object: T) {
        self.init()
        dump(object, to: &self)
    }
}
