import inspect
import re
from typing import Any, Callable, Dict, List, Tuple

from pydantic import BaseModel


class HTTPException(Exception):
    def __init__(self, status_code: int, detail: str | None = None):
        self.status_code = status_code
        self.detail = detail


class FastAPI:
    def __init__(self, title: str | None = None):
        self.routes: List[Tuple[str, Callable, List[str]]] = []

    def add_api_route(self, path: str, endpoint: Callable, methods: List[str]):
        self.routes.append((path, endpoint, [m.upper() for m in methods]))

    def _route(self, path: str, methods: List[str]):
        def decorator(func: Callable):
            self.add_api_route(path, func, methods)
            return func
        return decorator

    def get(self, path: str, response_model: Any | None = None):
        return self._route(path, ["GET"])

    def post(self, path: str, response_model: Any | None = None):
        return self._route(path, ["POST"])

    def put(self, path: str, response_model: Any | None = None):
        return self._route(path, ["PUT"])

    def delete(self, path: str, response_model: Any | None = None):
        return self._route(path, ["DELETE"])

    def add_middleware(self, middleware_cls, **kwargs):
        # Middleware is ignored in this lightweight implementation
        pass


from .middleware.cors import CORSMiddleware




class Response:
    def __init__(self, status_code: int, json_data: Any):
        self.status_code = status_code
        self._json = json_data

    def json(self) -> Any:
        return self._json


class TestClient:
    def __init__(self, app: FastAPI):
        self.app = app

    def _find_route(self, method: str, path: str):
        for route_path, endpoint, methods in self.app.routes:
            if method.upper() not in methods:
                continue
            pattern = "^" + re.sub(r"{([^}]+)}", r"(?P<\1>[^/]+)", route_path) + "$"
            match = re.match(pattern, path)
            if match:
                return endpoint, {k: v for k, v in match.groupdict().items()}
        return None, None

    def _call(self, method: str, path: str, json: Dict[str, Any] | None = None):
        endpoint, params = self._find_route(method, path)
        if endpoint is None:
            return Response(404, {"detail": "Not Found"})
        params = params or {}
        sig = inspect.signature(endpoint)
        kwargs = {}
        for name, param in sig.parameters.items():
            if name in params:
                value = params[name]
                if param.annotation not in (inspect._empty, str):
                    try:
                        value = param.annotation(value)
                    except Exception:
                        pass
                kwargs[name] = value
            else:
                if json is not None:
                    if (
                        param.annotation is not inspect._empty
                        and isinstance(param.annotation, type)
                        and issubclass(param.annotation, BaseModel)
                    ):
                        kwargs[name] = param.annotation(**json)
                    else:
                        kwargs[name] = json
        try:
            result = endpoint(**kwargs)
            status = 200
            if isinstance(result, BaseModel):
                body = result.model_dump()
            else:
                body = result
            if isinstance(body, tuple) and len(body) == 2:
                body, status = body
            return Response(status, body)
        except HTTPException as exc:
            return Response(exc.status_code, {"detail": exc.detail})

    def get(self, path: str):
        return self._call("GET", path)

    def post(self, path: str, json: Dict[str, Any] | None = None):
        return self._call("POST", path, json)

    def put(self, path: str, json: Dict[str, Any] | None = None):
        return self._call("PUT", path, json)

    def delete(self, path: str):
        return self._call("DELETE", path)


__all__ = [
    'FastAPI',
    'HTTPException',
    'TestClient',
    'CORSMiddleware',
    'Response',
]
