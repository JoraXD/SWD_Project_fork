from dataclasses import dataclass, asdict

class BaseModel:
    def __init__(self, **data):
        # Collect annotations from all bases
        fields = {}
        for cls in reversed(self.__class__.mro()):
            fields.update(getattr(cls, '__annotations__', {}))
        for field in fields:
            setattr(self, field, data.get(field))

    def dict(self):
        result = {}
        for cls in reversed(self.__class__.mro()):
            for field in getattr(cls, '__annotations__', {}):
                result[field] = getattr(self, field)
        return result

    def model_dump(self):
        return self.dict()
