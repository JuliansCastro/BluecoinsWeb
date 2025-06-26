class BluecoinsDBRouter:
    """
    Router for any 'BluecoinsWeb_app' model to use the 'bluecoins' DB.
    All other models will use the default DB.
    """
    route_app_labels = {'BluecoinsWeb_app'}  # the name of your app

    def db_for_read(self, model, **hints):
        if model._meta.app_label in self.route_app_labels:
            return 'bluecoins'  # Name of the DB defined in settings.py
        return None

    def db_for_write(self, model, **hints):
        if model._meta.app_label in self.route_app_labels:
            return 'bluecoins'
        return None

    def allow_relation(self, obj1, obj2, **hints):
        # Allow relationships if both objects are in 'BluecoinsWeb_app'
        if (
            obj1._meta.app_label in self.route_app_labels and
            obj2._meta.app_label in self.route_app_labels
        ):
            return True
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        # Avoid migrations in the 'bluecoins' database
        if app_label in self.route_app_labels:
            return db == 'bluecoins'  # Normally you can set it to False to block
        return None
