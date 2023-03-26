const ensureSyncableLoaded = (syncable, expectedDatum) => {
  if (syncable?.loading) return 'loading';
  if (syncable?.error) return 'error';
  if (!syncable?.sync) {
    return 'start-load';
  }
  if (syncable.sync && (!syncable.data.map((d) => expectedDatum(d)).reduce((a,b)  => a&&b, true))) {
    return 'start-load';
  }
  return 'loaded';
}

const ensureSyncableListLoaded = (syncable) => {
  if (syncable?.loading) return 'loading';
  if (syncable?.error) return 'error';
  if (!syncable?.sync) {
    return 'start-load';
  }
  return 'loaded';
}

export { ensureSyncableLoaded, ensureSyncableListLoaded };