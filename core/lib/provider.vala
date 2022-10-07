namespace Devident {
  public abstract class Provider : GLib.Object {
    internal Vdi.Container _container;

    public virtual string name {
      get {
        return this.get_type().name();
      }
    }

    construct {
      this._container = new Vdi.Container();
      this.init(this._container);
    }

    public abstract void init(Vdi.Container container);

    public DeviceProvider ? get_device_provider() {
      return this._container.get(typeof(DeviceProvider)) as DeviceProvider;
    }
  }
}
